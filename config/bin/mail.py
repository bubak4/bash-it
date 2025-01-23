#!/usr/bin/env python

# sends simple testing mail message to the mailbox given on the command line

import smtplib
import sys
import time

TO = list()
FROM = "mar@centrum.cz"
#FROM = "martin@slouf.name"
#FROM = "martin.slouf@justlogin.cz"
#FROM = "martin.slouf@gmail.com"
X_RYPOUS = __file__
SUBJECT = "test mail / zkouska mailu -- prosim neodpovidejte"

if (__name__ == "__main__"):
    if (len(sys.argv) != 2):
        print("E: wrong arguments")
        sys.exit(2)
    else:
        TO.append(sys.argv[1])
    msg = "From: %s\r\nTo: %s\r\nX-Rypous: %s\r\nSubject: %s\r\n\r\n" % \
          (FROM, ", ".join(TO), X_RYPOUS, SUBJECT)
    msg += "current timestamp: %d\r\n" % (time.time())
    msg += "odeslano spravcem mailu\r\n"
    print(msg)
    server = smtplib.SMTP('localhost')
    try:
        server.sendmail(FROM, TO, msg)
    except:
        pass
    finally:
        server.quit()
