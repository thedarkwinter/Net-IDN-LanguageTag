#!/usr/bin/perl -w

use 5.010;
use strict;
use warnings;
use Test::More tests => 50;
use Net::IDN::LanguageTag;
use Data::Dumper;

my $lt = Net::IDN::LanguageTag->new();
isa_ok($lt,'Net::IDN::LanguageTag');


## Test the _IS_ISO methods
is($lt->_is_iso639_1('en'),1,'_is_iso639_1 valid');
is($lt->_is_iso639_1('za'),1,'_is_iso639_1 valid');
is($lt->_is_iso639_1('qq'),undef,'_is_iso639_1 invalid');
is($lt->_is_iso639_2('eng'),1,'_is_iso639_2 valid');
is($lt->_is_iso639_2('fre'),1,'_is_iso639_2 valid');
is($lt->_is_iso639_2('qqq'),undef,'_is_iso639_2 invalid');
is($lt->_is_iso3166_1('GB'),1,'_is_iso3166_1 valid');
is($lt->_is_iso3166_1('FR'),1,'_is_iso3166_1 valid');
is($lt->_is_iso3166_1('QQ'),undef,'_is_iso3166_1 invalid');
is($lt->_is_iso15924('Phnx'),1,'_is_iso15924 valid');
is($lt->_is_iso15924(220),1,'_is_iso15924 valid');
is($lt->_is_iso15924('Zaza'),undef,'_is_iso15924 invalid');

## Test the IS_{natural} methods
is($lt->_is_language('English'),1,'_is_language valid');
is($lt->_is_language('Entish'),undef,'_is_language invalid');
is($lt->_is_country('France'),1,'_is_france valid');
is($lt->_is_country('Neverland'),undef,'_is_france valid');
is($lt->_is_script('Cyrillic'),1,'_is_script valid');
is($lt->_is_script('Squiggles'),undef,'_is_script valid');


## Test from _FROM methods

# FROM iso639_1
$lt->_reset();
$lt->_from_iso639_1('en');
is($lt->iso639_1(),'en','from iso639_1 -> iso639_1 (same)');
is($lt->iso639_2(),'eng','from iso639_1 -> iso639_2');
is($lt->language(),'English','from iso639_1 -> language');

# FROM iso639_2
$lt->_reset();
$lt->_from_iso639_2('eng');
is($lt->iso639_1(),'en','from iso639_2 -> iso639_1');
is($lt->iso639_2(),'eng','from iso639_2 -> iso639_2 (same)');
is($lt->language(),'English','from iso639_2 -> language');

# FROM iso3166_1
$lt->_reset();
$lt->_from_iso3166_1('GB');
is($lt->iso3166_1(),'GB','from iso3166_1 -> iso3166_1 (same)');
is($lt->country(),'United Kingdom','from iso3166_1 -> country');

# FROM iso15924
$lt->_reset();
$lt->_from_iso15924('Phnx');
is($lt->iso15924(),'Phnx','from iso15924 -> iso15924 (same)');

# FROM language
$lt->_reset();
$lt->_from_language('English');
is($lt->iso639_1(),'en','from language -> iso639_1');
is($lt->iso639_2(),'eng','from language -> iso639_2');
is($lt->language(),'English','from language -> language (same)');

# FROM country
$lt->_reset();
$lt->_from_country('France');
is($lt->iso3166_1(),'fr','from country -> iso3166_1');
is($lt->country(),'France','from country  -> country (same)');

# FROM script
$lt->_reset();
$lt->_from_script('Cyrillic');
is($lt->iso15924(),'Cyrl','from script -> iso15924');
is($lt->iso15924_numeric(),'220','from script -> iso15924_numeric');
is($lt->script(),'Cyrillic','from script -> script (same)');


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

# Autodetect [iso639_2-iso15924]
$lt->parse('en-Latn');
is ($lt->iso15924(),'Latn','AutoDetect iso15924 [iso639_2-iso15924]');
is ($lt->iso639_1(),'en','AutoDetect iso639_1 [iso639_2-iso15924]');
is ($lt->iso639_2(),'eng','AutoDetect iso639_2 [iso639_2-iso15924]');

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