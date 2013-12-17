#!/usr/bin/perl -w

use 5.010;
use strict;
use warnings;
use Test::More tests => 28;
use Net::IDN::LanguageTag;
use Data::Dumper;

my $lt = Net::IDN::LanguageTag->new();
isa_ok($lt,'Net::IDN::LanguageTag');

# FROM iso639_1
$lt->_reset();
$lt->_from_iso639_1('en');
is($lt->iso639_1(),'en','from iso639_1 -> iso639_1 (same)');
is($lt->iso639_2(),'eng','from iso639_1 -> iso639_2');
is($lt->iso15924(),undef,'from iso639_1 -> iso15924 (undef)');
is($lt->language(),'English','from iso639_1 -> language');

# FROM iso639_2
$lt->_reset();
$lt->_from_iso639_2('eng');
is($lt->iso639_1(),'en','from iso639_2 -> iso639_1');
is($lt->iso639_2(),'eng','from iso639_2 -> iso639_2 (same)');
is($lt->iso15924(),undef,'from iso639_2 -> iso639_2 (undef)');
is($lt->language(),'English','from iso639_2 -> language');

# FROM iso15924
$lt->_reset();
$lt->_from_iso15924('Phnx');
is($lt->iso639_1(),undef,'from iso15924 -> iso639_1 (undef)');
is($lt->iso639_2(),undef,'from iso15924 -> iso639_2 (undef)');
is($lt->iso15924(),'Phnx','from iso15924 -> iso15924 (same)');
is($lt->language(),undef,'from iso15924 -> language (undef)');

# FROM language
$lt->_reset();
$lt->_from_language('English');
is($lt->iso639_1(),'en','from language -> iso639_1');
is($lt->iso639_2(),'eng','from language -> iso639_2');
is($lt->iso15924(),undef,'from language -> iso15924 (undef)');
is($lt->language(),'English','from language -> language (same)');

# Autodetect [iso639_1]
$lt->parse('zh');
is ($lt->iso639_2(),'chi','AutoDetect [iso639_1]');

# Autodetect [iso639_2]
$lt->parse('chi');
is ($lt->iso639_1(),'zh','AutoDetect [iso639_2]');

# Autodetect [iso15924]
$lt->parse('Cyrl');
is ($lt->iso15924(),'Cyrl','AutoDetect [iso15924]');
is ($lt->iso15924_numeric(),220,'AutoDetect [iso15924_numeric]');

# Autodetect [iso15924]
$lt->parse('220');
is ($lt->iso15924(),'Cyrl','AutoDetect [iso15924]');
is ($lt->iso15924_numeric(),220,'AutoDetect [iso15924_numeric]');

# Autodetect [iso15924 long]
$lt->parse('und-Zyyy');
#is ($lt->iso15924(),'und-Zyyy','AutoDetect [iso15924 long]');

# Autodetect [language]
$lt->parse('Chinese');
is ($lt->iso639_2(),'chi','AutoDetect [language]');

# INVALID codes/language
$lt->parse('ac');
is ($lt->iso639_1(),undef,'Invalid iso639_1');
$lt->parse('acc');
is ($lt->iso639_2(),undef,'Invalid iso639_2');
$lt->parse('Hmns');
is ($lt->iso15924(),undef,'Invalid iso15924');
$lt->parse('Entish');
is ($lt->language(),undef,'Invalid language');

exit 0;