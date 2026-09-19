#!/usr/bin/env python
# Time-stamp: < gui.py (2019-08-04 07:54) >

from Tkinter import *
import xml.sax
import accounts

class MainFrame (Frame):

    def __init__(self, master):
        Frame.__init__(self, master)
        self.list = None
        self.editbtn = None
        self.quitbtn = None
        self.accounts = []
        handler = accounts.AccountHandler()
        xml.sax.parse(accounts.AccountParser.XML_FILE, handler)
        for i in handler.accounts:
            self.accounts.append(AccountPres(i))
        self._build_gui()

    def _build_gui(self):
        self.grid(sticky = N+E+S+W)
        scroll_frame = ScrollFrame(self, Listbox)
        scroll_frame.grid(row = 0, column = 0, columnspan = 2,
                          sticky = N+E+S+W)
        self.list = scroll_frame.widget
        self.list["width"] = 60
        self.list["height"] = 30
        self.list.grid_propagate(0)

        self.editbtn = Button(self, text = "Edit",
                              command = self._editbtn_clicked)
        self.editbtn.grid(row = 1, column = 0, sticky = E+W)

        self.quitbtn = Button(self, text = "Quit",
                              command = self._quitbtn_clicked)
        self.quitbtn.grid(row = 1, column = 1, sticky = E+W)

        self._accounts_to_list()

    def _accounts_to_list(self):
        for i in self.accounts:
            self.list.insert(END, i)

    def _editbtn_clicked(self):
        selection = self.list.curselection()
        if (len(selection) > 0):
            index = int(selection[0])
            print index
            print unicode(self.accounts[index])
            print unicode(self.accounts[index].account)

    def _quitbtn_clicked(self):
        self.quit()


class ScrollFrame (Frame):
    def __init__(self, master, widget_class):
        Frame.__init__(self, master)
        self.widget = widget_class(self)
        self.xscroll = Scrollbar(self, orient = HORIZONTAL,
                                 command = self.widget.xview)
        self.yscroll = Scrollbar(self, orient = VERTICAL,
                                 command = self.widget.yview)
        self.widget["xscrollcommand"] = self.xscroll.set
        self.widget["yscrollcommand"] = self.yscroll.set

        self.grid()
        self.widget.grid(row = 0, column = 0, sticky=N+E+S+W)
        self.xscroll.grid(row = 1, column = 0, sticky = E+W)
        self.yscroll.grid(row = 0, column = 1, sticky = N+S)

class AccountPres:
    def __init__(self, account):
        self.account = account

    def __str__(self):
        tmp = self.account.url
        return tmp

# - - - -

if (__name__ == "__main__"):
    app = Tk()
    app.title("Accounts GUI")
    main_frame = MainFrame(app)
    app.mainloop()
