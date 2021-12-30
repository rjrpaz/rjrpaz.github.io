---
layout: post
title:  "Create email for outlook using python"
date:   2021-12-29 00:00:00 -0300
categories: outlook python
---

This is an example of how to use python using outlook.

There are some cases when we need to use an email client to send an email instead of sending it using a python script in batch mode (typically using SMTP or SMTPAuth).

The script uses win32 calls to connect to Outlook, so this will run in Windows environments only.

## Install required libraries

I'm assuming you already installed Python3 in your Windows box.

You can create a virtual env to run the script. First, install the virtualenv module from a DOS console as follows:

```console
pip install virtualenv
```

Now create the virtualenv:

```console
virtualenv venv
```

Start the virtualenv:

```console
venv\Scripts\activate.bat
```

Inside virtualenv, install *pywin32* module:

```console
pip install pywin32
```

The virtual environment is ready to run a script like the following:

```console
#!/usr/bin/env python
import sys
import win32com.client as client

html_body = """
<div>
Hello. This is a sample email.
</div><br>
<div>
Using html will present the body in enriched format.
</div><br>
<div>
Check original documentation for pywin32 <a href='https://pypi.org/project/pywin32/'>here</a>
</div>
    """

recipient = "john@example.com"
cc = "peter@example.com"


def create_email(recipient, cc):
    """Create an email with summary information"""
    outlook = client.Dispatch('Outlook.Application')
    message = outlook.CreateItem(0)
    message.To = recipient
    message.CC = cc
#    message.Attachments.Add(file) # You can attach a file with this
    message.Subject = 'Mail sent using python + Outlook'
    message.HTMLBody = html_body
    message.Display()

def main():
    create_email(recipient, cc)

if __name__ == "__main__":
    main()
```

The result of running this is:

![Create an outlook email using python](/assets/images/Outlook from python.png)

This is an email ready to checked and sent.
