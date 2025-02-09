#!/usr/bin/env python3
# Time-stamp: <2025-01-23 18:12:40 martin>
"""
Simple script to configure DNS for home lan network.
"""

import logging
import sys

import pexpect

ETC_ETHERS = """
90:A4:DE:EB:80:D4 192.168.1.5
00:17:31:8B:3C:15 192.168.1.10
00:19:D2:96:E7:35 192.168.1.11
00:24:D7:13:71:60 192.168.1.12
6C:88:14:FF:53:78 192.168.1.13
70:85:C2:04:EA:9E 192.168.1.16
90:78:41:EE:F5:0C 192.168.1.17
00:2B:67:8E:53:DD 192.168.1.18
22:2E:D9:72:86:89 192.168.1.19
84:2A:FD:00:F8:D0 192.168.1.20
04:7B:CB:C7:BD:22 192.168.1.21
8C:3B:4A:AC:B5:03 192.168.1.22
"""

ETC_DNSMASQ_CONF_LAN = """
192.168.1.1      rt-n66u.lan            rt-n66u
#192.168.1.2      ea-n66.lan             ea-n66
#192.168.1.3      rt-n53.lan             rt-n53

192.168.1.5      onkyo.lan              onkyo

192.168.1.10     rypak.lan              rypak
192.168.1.11     chocholous-t60.lan     chocholous-t60
192.168.1.12     chocholous-t410s.lan   chocholous-t410s
192.168.1.13     x230.lan               x230
# 192.168.1.14     openelec.lan           openelec
# 192.168.1.15     odroid.lan             odroid               martin.slouf.lan
192.168.1.16     gamebox.lan            gamebox
192.168.1.17     x390.lan               x390
192.168.1.18     lanbox.lan             lanbox
192.168.1.19     workbox.lan            workbox
192.168.1.20     hp-printer.lan         hp-printer
192.168.1.21     t14s.lan               t14s
192.168.1.22     p14s.lan               p14s
"""

logging.basicConfig(
    format=
    '%(asctime)s - %(process)d-%(threadName)s-%(thread)d -- %(name)s - %(levelname)s - %(message)s',
    level=logging.DEBUG)

logger = logging.getLogger(__name__)


class Configurer(object):

    def __init__(self):
        self.child = self.__create_child()
        self.etc_dnsmasq_conf = "/etc/dnsmasq.conf"
        self.etc_dnsmasq_conf_lan = "/etc/dnsmasq.conf.lan"

    def __del__(self):
        """Exit running telnet and shell"""
        # remote shell
        self.child.sendline("exit")
        # local shell
        self.child.sendline("exit")

    def __create_child(self):
        """Creates a spawn process and logins to router."""
        child = pexpect.spawn("bash")
        child.sendline("telnet 192.168.1.1")
        child.expect("RT-N66U login:")
        child.sendline("admin")
        child.expect("Password:")
        child.sendline("huLu1tea")
        child.expect("admin@RT-N66U:")
        return child

    # FIXME martin.slouf -- not used now
    def append_to_dnsmasq_conf(self):
        cmd = "cat >> %s <<EOF" % (self.etc_dnsmasq_conf, )
        self.child.sendline(cmd)
        self.child.expect("> ")
        self.child.sendline(ETC_DNSMASQ_CONF)
        self.child.expect("> ")
        self.child.sendline("EOF")

    def create_dnsmasq_conf_lan(self):
        cmd = "cat > %s <<EOF" % (self.etc_dnsmasq_conf_lan, )
        self.child.sendline(cmd)
        self.child.expect("> ")
        self.child.sendline(ETC_DNSMASQ_CONF_LAN)
        self.child.expect("> ")
        self.child.sendline("EOF")

    def restart_dnsmasq(self):
        self.child.sendline(
            "kill `ps | fgrep -e dnsmasq | head -1 | cut -c-6`")
        self.child.expect("admin@RT-N66U:")
        self.child.sendline(
            f"dnsmasq --local=/lan/ --addn-hosts={self.etc_dnsmasq_conf_lan} --log-async &"
        )
        self.child.expect("admin@RT-N66U:")


if __name__ == """__main__""":

    update = False
    if len(sys.argv) > 1:
        update = True

    configurer = Configurer()

    # if (not update):
    #     configurer.append_to_dnsmasq_conf()
    configurer.create_dnsmasq_conf_lan()
    configurer.restart_dnsmasq()
