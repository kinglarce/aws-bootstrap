#!/bin/bash
# Codedeploy doesn't preserve symlinks.
# pm2 binary doesn't work unless it's a symlink to the node_modules/pm2 dir.
# So, here we make pm2 binary a symlink.

source /home/ec2-user/.bash_profile
cd /home/ec2-user/app/release/node_modules/.bin
rm pm2
ln -s ../pm2/bin/pm2 pm2