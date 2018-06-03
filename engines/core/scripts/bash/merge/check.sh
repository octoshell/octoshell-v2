#!/bin/bash
function do_task
{
  RAILS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../../.."
  (cd $RAILS_DIR && bundle exec rake RAILS_ENV=production  core:"$1")
}

do_task check_employments && do_task check_projects && do_task check_cities && do_task check_organizations
