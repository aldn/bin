#!/usr/bin/perl

# perl script for my email subscribes. Purge all mail headers and advertising!
# (c) 2003 Alexander Dunayevskyy
# MIT License


while (<>) {
    switch: {
	# this is encountered once per message
	# (print some kind of delimiter...)
	/^From\s/  && do { 
	    # print "----\n" ;
	    last switch; };

	# skip this line
	(
	    /^Return-Path/ ||
	    /^X-/ ||
	    /^Received/ ||
	    /^\s\sby/ ||
	    /^\s\swith/ ||
	    /^Message/ ||
	    /^List-/ ||
	    /^Date/ ||
	    /^From/ ||
	    /^To/ ||
	    /^Subject/ ||
	    /^MIME/ ||
	    /^Content/ ||
	    /^Status/ ||
	    /^Precedence/ ||
	    /\=\?/ ||
	    /Информационный канал Subscribe.Ru/ ||
	    /----------/ ||
	    /\=\=\=\=\=\=\=\=\=\=/ ||
	    /Fomenko.Ru/ ||
	    /::/ ||
	    /http/ ||
	    /mailto/ ||
	    /анекдотов.net/ ||
	    /рассылки/ ||
	    /Рассылки/ ||
	    /Знаете ли Вы, что/ ||
	    /Подпишитесь/ ||
	    /Подписаться/ ||
	    /Отписаться/ ||
	    /реклама/ ||
	    /Реклама/ ||
	    /посетите/ ||
	    /сайт/

	) && last switch;

	# print this line
	print;
    }
}
