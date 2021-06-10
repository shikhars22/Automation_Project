##################################################
####  Do this before executing automation.sh
#########################################################
#sudo su
#sudo ./root/Automation_Project/automation.sh
#chmod 777 automation.sh
#####################################################
## 5JAG5TDvQ5ZYZ3x
######To check if Apache2 is installed or not ###########
isApacheInstalled=$(( `dpkg --get-selections | grep apache | wc -l` ))
#echo $isApacheInstalled

if [ $isApacheInstalled == 0 ] 
then
    echo "Apache not installed"
    sudo apt update -y
    sudo apt update
    sudo apt install apache2
else
    echo "Apache already installed"
fi

isApacheRunning=$(( `sudo systemctl status apache2 | grep active | wc -l` ))
if [ $isApacheRunning == 1 ]
then
    echo "Apache server is running"
else
    echo "Apache is server is not running"
    sudo systemctl start apache2
    sudo systemctl enable apache2
fi

######To check if AWS CLI is installed or not ###########
isAwsCliInstalled=$(( `dpkg --get-selections | grep awscli | wc -l` ))
#echo $isAwsCliInstalled

if [ $isAwsCliInstalled == 0 ]
then
    echo "AWS CLI not installed"
    sudo apt update
    sudo apt install awscli
else
    echo "AWS CLI is already installed"
fi

######To create tar file of apache log files ###########
cd /var/log/apache2/
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="shikhar"
s3_bucket="upgrad-shikhar"
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


