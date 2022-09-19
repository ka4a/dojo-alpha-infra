#!/usr/bin/env bash

LOG_FILE=/edx/var/log/cron_tasks/edx.log
mkdir -p `dirname ${LOG_FILE}`
exec &>> ${LOG_FILE}
exec 2>&1

if test -f /tmp/stop-edxapp-cron ; then
  echo `date '+%Y-%m-%d %H:%M:%S'`,000 === Exiting. /tmp/stop-edxapp-cron file exists
  exit 0
fi

# random delay for multi-instance installations, where multiple instances runs this task simultaneously
# packer build instance also run this tasks
RAND=`head -c 1 /dev/urandom | od -t u1 | cut -c9-`
sleep `expr ${RAND} % 90 + 1`

echo `date '+%Y-%m-%d %H:%M:%S'`,000 === Start updating LMS programs cache
. ~edxapp/edxapp_env
cd ~edxapp/edx-platform
sudo -Eu www-data ~edxapp/venvs/edxapp/bin/python ./manage.py lms cache_programs --settings=production

echo `date '+%Y-%m-%d %H:%M:%S'`,000 === Start updating discovery metadata
. ~discovery/discovery_env
cd ~discovery/discovery
sudo -Eu discovery ~discovery/venvs/discovery/bin/python -W ignore ./manage.py refresh_course_metadata
sudo -Eu discovery ~discovery/venvs/discovery/bin/python -W ignore ./manage.py remove_unused_indexes
sudo -Eu discovery ~discovery/venvs/discovery/bin/python -W ignore ./manage.py update_index --disable-change-limit
deactivate || true

echo `date '+%Y-%m-%d %H:%M:%S'`,000 === Start updating enterprise_catalog metadata
. ~enterprise_catalog/enterprise_catalog_env
cd ~enterprise_catalog/enterprise_catalog
sudo -Eu enterprise_catalog ~enterprise_catalog/venvs/enterprise_catalog/bin/python -W ignore ./manage.py update_content_metadata
