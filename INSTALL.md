# Install Open Source Event Manager
All the information that you need to install OSEM. If you have any problems with installing don't hesitate to [contact us](https://github.com/openSUSE/osem#contact)

## Versions
OSEM is an [semantic versioned](http://semver.org/) app. That means given a version number MAJOR.MINOR.PATCH we increment the:

1. MAJOR version when we make incompatible changes,
2. MINOR version when we add functionality in a backwards-compatible manner
3. PATCH version when we make backwards-compatible bug fixes

## Download
You can find the latest OSEM releases on our [release page](https://github.com/openSUSE/osem/releases/latest) ([older release here](https://github.com/openSUSE/osem/releases))

## Deploy
OSEM is a *Ruby on Rails* application. We recommend to run OSEM in production with [mod_passenger](https://www.phusionpassenger.com/download/#open_source)
and the [apache web-server](https://www.apache.org/). There are tons of guides on how to deploy rails apps on various
base operating systems. [Check Google](https://encrypted.google.com/search?hl=en&q=ruby%20on%20rails%20apache%20passenger) ;-)

For more information about rails and what it can do, see the [rails guides.](http://guides.rubyonrails.org/getting_started.html)

If you have an heroku account you can also

<a href="https://heroku.com/deploy?template=https://github.com/openSUSE/osem/tree/v1.0">
  <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy">
</a>

## Configure
There are a couple of environment variables you can set to configure OSEM. Check out the *dotenv.example* file.

| Variable 			| Content 			| Purpose 				|
|----------			|---------			|---------	       			|
| OSEM_NAME   			| openSUSE Events		| The name of your page			|
| OSEM_HOSTNAME 		| events.opensuse.org		| The host this OSEM instance runs on 	|
| OSEM_EMAIL_ADDRESS 		| events@opensuse.org 		| The address OSEM uses for sending mails |
| OSEM_ICHAIN_ENABLED 		| true/false 			| Enable the usage of [devise_ichain_authenticatable](https://github.com/openSUSE/devise_ichain_authenticatable) |
| OSEM_TRANSIFEX_APIKEY 	| *string* 			| Use this api key for [transifex](https://www.transifex.com/). See TRANSLATION.md for details. |
| OSEM_ERRBIT_HOST 		| errbit.opensuse.org 		| The [errbit](https://github.com/errbit/errbit) host to post exceptions to |
| OSEM_ERRBIT_APIKEY 		| *string* 			| The api key for the errbit host |
| OSEM_FACTORY_LINT		| *boolean* (true/false)        | Setting this to false will disable linting of factories before running spec
| OSEM_GOOGLE_KEY | *string*			| OMNIAUTH Developer Key for GOOGLE
| OSEM_GOOGLE_SECRET | *string*			| OMNIAUTH Developer Secret for GOOGLE
| OSEM_FACEBOOK_KEY | *string*		| OMNIAUTH Developer Key for Facebook
| OSEM_FACEBOOK_SECRET | *string*		| OMNIAUTH Developer Secret for Facebook
| OSEM_GITHUB_KEY | *string*			| OMNIAUTH Developer Key for GitHub
| OSEM_GITHUB_SECRET | *string*			| OMNIAUTH Developer Secret for GitHub
| OSEM_SUSE_KEY | *string*			| OMNIAUTH Developer Key for openSUSE
| OSEM_SUSE_SECRET | *string*			| OMNIAUTH Developer Secret for openSUSE
| OSEM_SMTP_ADDRESS		| smtp.opensuse.org		| The smtp server to use
| OSEM_SMTP_PORT		| *int*				| The port on the smtp server
| OSEM_SMTP_USERNAME		| *string*			| The user for the smtp server
| OSEM_SMTP_PASSWORD		| *string*			| The password for the smtp server
| OSEM_SMTP_AUTHENTICATION	| plain, login or cram_md5      | The auth method for the smtp server
| OSEM_SMTP_DOMAIN		| opensuse.org			| The HELO domain for the smtp server
| CLOUDINARY_URL		| *string*			| Configure your cloudinary.com cloud name and api key/secret
| STRIPE_PUBLISHABLE_KEY    | *string*          | Publishable Key for Stripe Gateway
| STRIPE_SECRET_KEY    | *string*          | Secret Key for Stripe Gateway

### Online Ticket Payments
We use [Stripe](https://stripe.com) for accepting your ticket payments securely over the web.
Our application uses iFrame for accepting your user's payment details without storing them, making the application PCI SAQ-A Compliant.
Please refer to [PAYMENTS](PAYMENTS.md) documentation file for setting up your stripe account and start accepting payments from your users.

## Dependencies

### ImageMagick
We use [ImageMagick](http://imagemagick.org/) for image manipulation so it needs to be available in your installation.
If you would like to resize exisiting logos in your OSEM installation you can do so by running the following rake task:

```shell
$ bundle exec rake logo:reprocess
```

### openID
In order to use [openID](http://openid.net/) logins for your OSEM installation you need to register your application with the providers ([Google](https://code.google.com/apis/console#:access), [GitHub](https://github.com/settings/applications/new) or [Facebook](https://developers.facebook.com/)) and enter their API keys in the environment variables found in your *.env* file(s).

## Recurring Jobs
Open a separate terminal and go into the directory where the rails app is present, and type the following to start the delayed_jobs worker for sending email notifications.
```
bundle exec rake jobs:work
```

## Setting up OSEM for the first time
Once after hosting OSEM, it is necessary to know that all conferences in OSEM belongs to their organizations. Hence, no conference can be created until and unless there is an organization created first.

To make it simple, this is how you can get started with OSEM:

### Step 1: Sign Up
Sign up in your hosted version. Keep in mind, the first user to sign up on OSEM will become the site administrator. A site administrator can add other site administrators and has access to all data within the hosted version (except the encrypted one! duh!)

To sign up, follow the `Sign Up` link on the home page:
![Alt Text](https://user-images.githubusercontent.com/14155445/27461064-a7b77aa6-57d5-11e7-9feb-5f0c89f95907.png)

### Step 2: Create an organization
An organization in OSEM is your client organization who wants to host their conferences in your hosted version of OSEM. This step is necessary to group conferences that belong to the same organization together.

You can create an organization, if you sign in as an admin, from the navbar menu available on all views:
![Alt Text](https://user-images.githubusercontent.com/14155445/27415239-9b7807a4-5723-11e7-85f3-3bfa6ceee354.png)

### Step 3: Assign organization administrators
Organization administrators are people of that particular organization who have access to all parts of the organization as well as its conferences.

After creating organization, head over to the index page of organizations ( `/admin/organizations` ) to assign organization admins to it.
![Alt Text](https://user-images.githubusercontent.com/14155445/27460489-d3ff3314-57d1-11e7-8d90-345692a60292.png)
![Alt Text](https://user-images.githubusercontent.com/14155445/27460488-d3fcbb20-57d1-11e7-8714-c3b6c1a0e323.png)

For details about each role in OSEM, head over to our wiki.  
as they say, _with great power comes great responsibility!_
