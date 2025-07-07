#!/usr/bin/env python

# sends simple testing mail message to the mailbox given on the command line

import dataclasses
import os.path
import pprint
import smtplib
import sys
import time
import typing

FROM = "mar@centrum.cz"
#FROM = "martin@slouf.name"
#FROM = "martin.slouf@justlogin.cz"
#FROM = "martin.slouf@gmail.com"
X_RYPOUS = __file__
SUBJECT = "test mail -- do not answer / zkouska mailu -- prosim neodpovidejte"
BODY = """current time / aktualni cas: %s
sent by postmaster / odeslano spravcem mailu
""" % (time.strftime("%Y-%m-%d %H:%M:%S"))

@dataclasses.dataclass
class Mail:
    sender: str
    recipients: typing.List[str]
    subject: str
    body: typing.Optional[str]
    custom_headers: typing.Optional[typing.Dict[str, str]]

    def create_message(self):
        headers = {}
        headers["From"] = self.sender
        headers["To"] = ", ".join(self.recipients)
        headers["Subject"] = self.subject
        headers.update(self.custom_headers)

        msg = "\r\n".join(["%s: %s" % (k, v) for (k, v) in headers.items()])
        msg += "\r\n\r\n"
        msg += self.body

        return msg

    def send_via_localhost(self):
        msg = self.create_message()
        server = smtplib.SMTP('localhost')
        try:
            server.sendmail(self.sender, self.recipients, msg)
        finally:
            server.quit()

def usage():
    name = os.path.basename(sys.argv[0])
    print("Usage: %s <recipient>" % (name))

if (__name__ == "__main__"):    
    if (len(sys.argv) != 2):
        usage()
        sys.exit(2)
    else:
        recipient = sys.argv[1]

    mail = Mail(FROM, [recipient], SUBJECT, BODY, {"X-Rypous": X_RYPOUS})
    pprint.pprint(mail, width=120)
    mail.send_via_localhost()
