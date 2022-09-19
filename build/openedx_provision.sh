#!/bin/sh

set -x
set -e

test -z "${OPENEDX_RELEASE}" && ( echo "OPENEDX_RELEASE env var must be defined" ; exit 1)
test -z "${ENVIRONMENT}" && ( echo "ENVIRONMENT env var must be defined" ; exit 1)
test -z "${AMI_NAME}" && ( echo "AMI_NAME env var must be defined" ; exit 1)
test -z "${ANSIBLE_VAULT_PASSWORD_FILE}" && ( echo "ANSIBLE_VAULT_PASSWORD_FILE env var must be defined" ; exit 1)

# make sure unattended upgrades is not running to not run updates in parallel
sudo systemctl stop unattended-upgrades.service

# MySQL key update
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 467B942D3A79BD29

# make sure AWS SSM agent installed and launched

sudo apt-get update
sudo apt-get install snapd || true
sudo snap install amazon-ssm-agent || true
sudo snap enable amazon-ssm-agent || true
sudo snap start amazon-ssm-agent || true
sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent || true
sudo systemctl add-wants snap.amazon-ssm-agent.amazon-ssm-agent.service cloud-init.target || true
if ! grep -q snap.amazon-ssm-agent.amazon-ssm-agent /etc/crontab ; then
  echo '*/11 * * * * root sh -c "if tail -n 1 /var/log/amazon/ssm/amazon-ssm-agent.log | grep -q timeout ; then systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent  ; fi"' | sudo tee -a /etc/crontab
fi

# stop logging to CloudWatch from AMI build instance
sudo systemctl stop amazon-cloudwatch-agent.service || true

# keep Ubuntu updated with latest security patches and kernel

# uninstall Ubuntu telemetry
sudo apt-get remove -y ubuntu-advantage-tools lxcfs open-iscsi popularity-contest apport whoopsie python3-apport python3-problem-report sosreport update-notifier-common || true
sudo apt-get remove -y ubuntu-report || true
sudo rm -f /etc/default/motd-news.dpkg-bak
echo 'ENABLED=0' | sudo tee /etc/default/motd-news
# update Ubuntu kernel
sudo apt-get install -y linux-aws linux-headers-aws linux-image-aws
# let apt upgrade to install new configurtion for security updates
# edX configuration playbooks should apply all necessary changes
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confnew" upgrade
sudo apt-get -y autoremove
sudo apt-get clean

# OpenEdx Native Installation bootstrap
# run only for the very first time

if ! test -e ~edx-ansible/venvs/edx_ansible/bin/ansible-playbook ; then
  rm -rf /tmp/configuration
  wget https://raw.githubusercontent.com/edx/configuration/${OPENEDX_RELEASE}/util/install/ansible-bootstrap.sh -O - | sudo -E bash
  pip3 install pymongo==3.10.1
else
  sudo chown -R edx-ansible:edx-ansible /edx/app/edx_ansible
  cd /edx/app/edx_ansible/edx_ansible
  sudo -u edx-ansible git fetch --tags
  sudo -u edx-ansible git reset --hard ${OPENEDX_RELEASE}
fi

. /edx/app/edx_ansible/venvs/edx_ansible/bin/activate

cd /edx/app/edx_ansible/edx_ansible/playbooks

# transfer custom playbooks here
sudo rm -f openedx_ansible*
sudo -u edx-ansible cp ~/openedx_ansible* .

# reduce ansible output by silencing "skipped" tasks
if ! grep -q display_skipped_hosts ansible.cfg ; then
  sudo sed -i 's/jinja2_extensions=jinja2.ext.do/jinja2_extensions=jinja2.ext.do\ndisplay_skipped_hosts=no/' ansible.cfg
fi

# apply deploy speedup patches
sudo -u edx-ansible git -c user.name='OpenEdx provision script' -c user.email='deploy@strata.co.jp' -C /edx/app/edx_ansible/edx_ansible apply playbooks/openedx_ansible_mfe_speedup.patch
sudo -u edx-ansible git -c user.name='OpenEdx provision script' -c user.email='deploy@strata.co.jp' -C /edx/app/edx_ansible/edx_ansible apply playbooks/openedx_ansible_edxapp_speedup.patch

# to be able to make git clone in ansible playbooks we need to clean code
# directories for all customized applications
# changes made by sentry integration task
if test -f /edx/app/edxapp/edx-platform/lms/envs/production.py ; then
  sudo -u edxapp git -C /edx/app/edxapp/edx-platform/ checkout /edx/app/edxapp/edx-platform/
fi
# same for license_manager
if test -f /edx/app/license_manager/license_manager/license_manager/settings/production.py ; then
  sudo -u license_manager git -C /edx/app/license_manager/license_manager/ checkout /edx/app/license_manager/license_manager/
fi
# same for discovery
if test -f /edx/app/discovery/discovery/course_discovery/settings/production.py ; then
  sudo -u discovery git -C /edx/app/discovery/discovery/ checkout /edx/app/discovery/discovery/
fi
# same for enterprise_catalog
if test -f /edx/app/enterprise_catalog/enterprise_catalog/enterprise_catalog/settings/production.py ; then
  sudo -u enterprise_catalog git -C /edx/app/enterprise_catalog/enterprise_catalog/ checkout /edx/app/enterprise_catalog/enterprise_catalog/
fi

# free some memory for provision tasks
if test -f /edx/bin/supervisorctl ; then
  sudo /edx/bin/supervisorctl stop all
fi

touch /tmp/stop-edxapp-cron

time ansible-playbook -i,localhost -c local openedx_ansible.yaml \
  -e@~/config_common.yml \
  -e@~/config_${ENVIRONMENT}.yml \
  -e@~/config_${ENVIRONMENT}.vault \
  -e@~/config_${ENVIRONMENT}_tf.yml $*

sudo rm -rf /tmp/mako_lms /tmp/mako_cms
sudo chown -R www-data:edxapp /edx/var/edxapp/data
sudo chmod -R g+w /edx/var/edxapp/data
sudo /edx/bin/supervisorctl start all
rm -f /tmp/stop-edxapp-cron
