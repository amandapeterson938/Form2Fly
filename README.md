# Form2Fly

Form2Fly is a disc golf form analyzer made for iOS devices. 

## Form2Fly Team
* Cameron Hunt
* Alec Adams
* Keith Dixon
* Mickey Meyer
* Amanda Peterson
* Edward Ybarra

## Installation
To get Form2Fly running on your Mac you will need to begin by downloading some software. Some prerequisites are as follows you have to have Xcode installed on your machine and have an AWS account before beginning the installation instructions.

First go to https://nodejs.org/en/download/ and download Node.js LTS. Next open your terminal and execute the following command

```bash
sudo gem install cocoapods
```

Then install the Amplify CLI

```bash
npm install -g @aws-amplify/cli
```

Next you will need to go to our repository and click "Download zip".

Following this you will need to navigate to your terminal and go to that directory which should look something like the command below.

```bash
cd /Users/yourname/Downloads/Form2Fly-main
```

Now we can initialize Amplify by running 

```bash
amplify configure
```
This will open up your default browser where you will be able to sign in to your AWS account once you are signed in press enter in the terminal. Next you will have to select your AWS region that you selected when you created your AWS account. This will allow you to create a new IAM user which you will confirm in another popup window. You will need to make sure this IAM user has Programmatic access checked and AdministratorAccess permissions. 

Once you finished this will give you an Access Key ID and a secret access key make sure to make note of this and download the csv file and keep it in a safe space. Next on the terminal you will type in the access key id and secret access key. Now you will either type in what you want this user to be called on your machine or you can accept the "default" name. 

Subsequently you will need to run 

```bash
amplify init
```

Following this you will be given the opportunity to name your project or accept the default value given. 
Similarly you will do the same for the name of the environment. Next you will choose your default editor which will be "Xcode (Mac OS only)". Continuing on you will select the type of app which is "ios". 
Now you can either select "AWS access keys". In this case open the csv file that you downloaded earlier in this tutorial and input your accessKeyId, secretAccessKey, and region. 

Or you can select "AWS profile" and select the profile name that you set up in the "amplify configure" step.

Next we will add authentication to our project by running
```bash
amplify add auth
```
The terminal will ask you a series of questions. You will want to use the default configuration for the authentication and security configuration, give users the ability to sign in with a username, and you will select "No, I am done." when it asks if you want to configure advanced settings. 

Next you will push the changes to your account by running
```bash
amplify push
```

Now you will need to run 
```bash
pod init
```

Next you will need to edit the Podfile, below "Pods for Form2FlyUI" insert
```bash
pod 'GoogleMLKit/PoseDetectionAccurate'
pod 'Amplify', '~> 1.0'
pod 'Amplify/Tools', '~> 1.0'
pod 'AmplifyPlugins/AWSCognitoAuthPlugin', '~> 1.0'
```

After saving the Podfile please run
```bash
pod install
```

Then finally you can open the project by executing 
```bash
open Form2FlyUI.xcworkspace
```

After Xcode opens you will need to update "Signing and Capabilities" so it is under your Team. Then you will be able to run it on a physical device. 
