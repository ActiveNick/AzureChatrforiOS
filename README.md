AzureChatrforiOS
================

iOS Client for a Cloud-based Cross-Platform Chat App for iPhone and iPad. Written in Objective-C as a native app using Xcode.

WELCOME TO AZURECHATR!
----------------------

AzureChatr is a cross-platform chat client used by Microsoft Senior Technical
Evangelist Nick Landry to demonstrate mobile development techniques with a 
cloud backend using Microsoft Azure. While AzureChatr can be used to chat about
anything, the intent of the app is to bring users together to talk about cloud
development.

This is the prototype client of AzureChatr for iOS and is not published yet.
AzureChatr has already been published to the store on Windows Phone 8.1 and will
soon be available on Windows 8.1, iOS and Android.

Visit www.AgeofMobility.com for more info on the current and upcoming features.


BEFORE YOU RUN THE APP FOR THE FIRST TIME
-----------------------------------------
If you try to run the app as soon as you open it on your Mac in Xcode,
you will notice that the app will fail due to missing Cloud services.
You must create your own Azure account and configure the following Azure 
services to implement your own working version of AzureChatr:

- Azure Mobile Services
- Azure Notification Hubs

For more information on configuring the cloud services for AzureChatr, please
visit my blog at www.AgeofMobility.com. All configured app keys and secrets
are declared in the AZCChatService.m and AZCAppDelegate.m files.

