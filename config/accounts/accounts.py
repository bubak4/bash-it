#!/usr/bin/env python3
# Time-stamp: < accounts.py (2019-07-09 22:36) >

import copy
import os.path
import sys
import xml.sax

import readline


class Account(object):

    TERMINAL_ENCODING = "utf-8"

    def __init__(self):
        self.url = ""
        self.type = ""
        self.login_url = ""
        self.login_name = ""
        self.password = ""
        self.note = ""

    def __str__(self):
        tmp = """
        Acount url: %s
        type:       %s
        login_url:  %s
        login_name: %s
        password:   %s
        note:       %s
        """ % (self.url, self.type, self.login_url, self.login_name, self.password, self.note)
        return tmp

    def __bytes__(self):
        return self.__str__().encode(Account.TERMINAL_ENCODING)


class AccountHandler(xml.sax.handler.ContentHandler):

    def __init__(self):
        xml.sax.handler.ContentHandler.__init__(self)
        self.accounts = []
        self.current = None

    def setDocumentLocator(self, locator):
        xml.sax.handler.ContentHandler.setDocumentLocator(self, locator)

    def startDocument(self):
        xml.sax.handler.ContentHandler.startDocument(self)

    def endDocument(self):
        xml.sax.handler.ContentHandler.endDocument(self)

    def startPrefixMapping(self, prefix, uri):
        xml.sax.handler.ContentHandler.startPrefixMapping(self, prefix, uri)

    def endPrefixMapping(self, prefix):
        xml.sax.handler.ContentHandler.endPrefixMapping(self, prefix)

    def startElement(self, name, attrs):
        if name == "account":
            self.current = Account()
            self.current.url = attrs["url"]
            if "type" in attrs:
                self.current.type = attrs["type"]
            if "login_url" in attrs:
                self.current.login_url = attrs and attrs["login_url"]
            self.current.login_name = attrs["login_name"]
            self.current.password = attrs["password"]
            if "note" in attrs:
                self.current.note = attrs["note"]

    def endElement(self, name):
        if name == "account":
            self.accounts.append(self.current)
            self.current = None

    def startElementNS(self, name, qname, attrs):
        pass

    def endElementNS(self, name, qname):
        pass

    def characters(self, characters):
        pass

    def ignorableWhitespace(self, whitespace):
        pass

    def processingInstruction(self, target, data):
        pass

    def skippedEntity(self, name):
        pass


class AccountParser(object):

    XML_FILE = os.path.join(os.path.dirname(__file__), "accounts.xml")

    def parse(self):
        handler = AccountHandler()
        xml.sax.parse(AccountParser.XML_FILE, handler)
        return handler.accounts


class Ui(object):

    def __init__(self, accounts):
        self.accounts = accounts

    def init_readline(self):
        readline.clear_history()

    def read_input(self, default=""):
        input_string = default
        try:
            input_string = input("""- - - -
End with Ctrl+C or Ctrl+D.  Search is case insensitive.
Enter part of the url / note or '--all' to print all.
- - - -
? """)
            input_string = input_string.strip().lower()
        except (EOFError, KeyboardInterrupt):
            raise EOFError()
        return input_string

    def find_and_print_accounts(self, input_string):
        matched_accounts = []
        if input_string == "--all":
            matched_accounts = copy.copy(self.accounts)
        else:
            for i in self.accounts:
                if input_string in i.url.lower() or input_string in i.note.lower():
                    matched_accounts.append(i)

        for i in matched_accounts:
            print(str(i))


def main(argv):
    """CLI entry point."""
    parser = AccountParser()
    ui = Ui(parser.parse())

    if len(argv) == 2:
        input_string = argv[1].strip().lower()
        ui.find_and_print_accounts(input_string)
    else:
        ui.init_readline()
        run = True
        while run:
            try:
                input_string = ui.read_input()
                if len(input_string) > 0:
                    ui.find_and_print_accounts(input_string)
            except EOFError:
                run = False


if __name__ == "__main__":
    main(sys.argv)
