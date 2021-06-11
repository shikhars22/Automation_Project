##################################################
####  Do this before executing automation.sh
#########################################################
#sudo su
#sudo ./root/Automation_Project/automation.sh
#chmod 777 automation.sh
#####################################################
######To check if Apache2 is installed or not ###########

timestamp=$(date '+%d%m%Y-%H%M%S')
myname="shikhar"
s3_bucket="upgrad-shikhar"

echo "-------------automation.sh--running on $timestamp------------" > $myname-automation-script-logs-$timestamp.log


isApacheInstalled=$(( `dpkg --get-selections | grep apache | wc -l` ))
echo "isApacheInstalled = $isApacheInstalled" >$myname-automation-script-logs-$timestamp.log


if [ $isApacheInstalled == 0 ] 
then
    echo "Apache not installed" >> $myname-automation-script-logs-$timestamp.log
    sudo apt update -y
    sudo apt install -y apache2
    echo "Apache is now installed" >> $myname-automation-script-logs-$timestamp.log
else
    echo "Apache already installed" >> $myname-automation-script-logs-$timestamp.log
fi

isApacheRunning=$(( `sudo systemctl status apache2 | grep active | wc -l` ))
echo "isApacheRunning = $isApacheRunning" >> $myname-automation-script-logs-$timestamp.log

if [ $isApacheRunning == 1 ]
then
    echo "Apache server is running" >> $myname-automation-script-logs-$timestamp.log
else
    echo "Apache is server is not running" >> $myname-automation-script-logs-$timestamp.log
    sudo systemctl start apache2
    sudo systemctl enable apache2
    echo "Apache is server is now running and enabled" >> $myname-automation-script-logs-$timestamp.log
fi

######To check if AWS CLI is installed or not ###########
isAwsCliInstalled=$(( `dpkg --get-selections | grep awscli | wc -l` ))
echo "isAwsCliInstalled = $isAwsCliInstalled" >> $myname-automation-script-logs-$timestamp.log

if [ $isAwsCliInstalled == 0 ]
then
    echo "AWS CLI not installed" >> $myname-automation-script-logs-$timestamp.log
    sudo apt update -y
    sudo apt install -y awscli
    echo "AWS CLI now installed" >> $myname-automation-script-logs-$timestamp.log
else
    echo "AWS CLI is already installed" >> $myname-automation-script-logs-$timestamp.log
fi

######To create tar file of apache log files ###########
cd /var/log/apache2/

find . -iname '*.log' -print0 | xargs -0 tar zcf $myname-httpd-logs-$timestamp.tar
echo "Tar file is created in /tmp/ and name of tar file is $myname-httpd-logs-$timestamp.tar"
echo "Contents of $myname-httpd-logs-$timestamp.tar are as follows:"
tar -tvf shikhar-httpd-logs-$timestamp.tar

mv $myname-httpd-logs-$timestamp.tar /tmp/$myname-httpd-logs-$timestamp.tar
cd /tmp/
ls -lah | grep $myname

###Moving tar file to s3 bucket##### 
aws s3 \
cp /tmp/$myname-httpd-logs-$timestamp.tar \
s3://$s3_bucket/$myname-httpd-logs-$timestamp.tar


