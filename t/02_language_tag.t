#!/usr/bin/perl -w

use 5.010;
use strict;
use warnings;
use Test::More tests => 83;
use Net::IDN::LanguageTag;
use Data::Dumper;

my $lt = Net::IDN::LanguageTag->new();
isa_ok($lt,'Net::IDN::LanguageTag');

################################################################################
## Test the _IS_ISO methods
is($lt->_is('iso639_1','en'),1,'_is_iso639_1 valid');
is($lt->_is('iso639_1','za'),1,'_is_iso639_1 valid');
is($lt->_is('iso639_1','qq'),undef,'_is_iso639_1 invalid');
is($lt->_is('iso639_2','eng'),1,'_is_iso639_2 valid');
is($lt->_is('iso639_2','fre'),1,'_is_iso639_2 valid');
is($lt->_is('iso639_2','qqq'),undef,'_is_iso639_2 invalid');
is($lt->_is('iso3166_1','GB'),1,'_is_iso3166_1 valid');
is($lt->_is('iso3166_1','FR'),1,'_is_iso3166_1 valid');
is($lt->_is('iso3166_1','QQ'),undef,'_is_iso3166_1 invalid');
is($lt->_is('iso15924','Phnx'),1,'_is_iso15924 valid');
is($lt->_is('iso15924',220),1,'_is_iso15924 valid');
is($lt->_is('iso15924','Zaza'),undef,'_is_iso15924 invalid');

## Test the IS_{natural} methods
is($lt->_is('language','English'),1,'_is_language valid');
is($lt->_is('language','Entish'),undef,'_is_language invalid');
is($lt->_is('country','France'),1,'_is_france valid');
is($lt->_is('country','Neverland'),undef,'_is_france valid');
is($lt->_is('script','Cyrillic'),1,'_is_script valid');
is($lt->_is('script','Squiggles'),undef,'_is_script valid');

################################################################################
### Test from _FROM methods

# FROM iso639_1
$lt->reset();
$lt->_from_iso639_1('en');
is($lt->iso639_1(),'en','from iso639_1 -> iso639_1 (same)');
is($lt->iso639_2(),'eng','from iso639_1 -> iso639_2');
is($lt->language(),'English','from iso639_1 -> language');

# FROM iso639_2
$lt->reset();
$lt->_from_iso639_2('eng');
is($lt->iso639_1(),'en','from iso639_2 -> iso639_1');
is($lt->iso639_2(),'eng','from iso639_2 -> iso639_2 (same)');
is($lt->language(),'English','from iso639_2 -> language');

# FROM iso3166_1
$lt->reset();
$lt->_from_iso3166_1('GB');
is($lt->iso3166_1(),'GB','from iso3166_1 -> iso3166_1 (same)');
is($lt->country(),'United Kingdom','from iso3166_1 -> country');

# FROM iso15924
$lt->reset();
$lt->_from_iso15924('Phnx');
is($lt->iso15924(),'Phnx','from iso15924 -> iso15924 (same)');

# FROM language
$lt->reset();
$lt->_from_language('English');
is($lt->iso639_1(),'en','from language -> iso639_1');
is($lt->iso639_2(),'eng','from language -> iso639_2');
is($lt->language(),'English','from language -> language (same)');

# FROM country
$lt->reset();
$lt->_from_country('France');
is($lt->iso3166_1(),'fr','from country -> iso3166_1');
is($lt->country(),'France','from country  -> country (same)');

# FROM script
$lt->reset();
$lt->_from_script('Cyrillic');
is($lt->iso15924(),'Cyrl','from script -> iso15924');
is($lt->iso15924_numeric(),'220','from script -> iso15924_numeric');
is($lt->script(),'Cyrillic','from script -> script (same)');

################################################################################
# Test _detect 
is_deeply( {$lt->_detect('en-GB')},{'iso639_1'=>'en','iso3166_1'=>'GB'},'_detect en-GB');
is_deeply( {$lt->_detect('eng-ZA')},{'iso639_2'=>'eng','iso3166_1'=>'ZA'},'_detect eng-ZA');

# RFC 'irregular'
SKIP: {
  skip "Irregular tags not [yet] supported",17;
  is_deeply( {$lt->_detect('en-GB-oed')},{},'_detect irregular en-GB-oed');
  is_deeply( {$lt->_detect('i-ami')},{},'_detect irregular i-ami');
  is_deeply( {$lt->_detect('i-bnn')},{},'_detect irregular i-bnn');
  is_deeply( {$lt->_detect('i-default')},{},'_detect irregular i-default');
  is_deeply( {$lt->_detect('i-enochian')},{},'_detect irregular i-enochian');
  is_deeply( {$lt->_detect('i-hak')},{},'_detect irregular i-hak');
  is_deeply( {$lt->_detect('i-klingon')},{},'_detect irregular i-klingon');
  is_deeply( {$lt->_detect('i-lux')},{},'_detect irregular i-lux');
  is_deeply( {$lt->_detect('i-mingo')},{},'_detect irregular i-mingo');
  is_deeply( {$lt->_detect('i-navajo')},{},'_detect irregular i-navajo');
  is_deeply( {$lt->_detect('i-pwn')},{},'_detect irregular i-pwn');
  is_deeply( {$lt->_detect('i-tao')},{},'_detect irregular i-tao');
  is_deeply( {$lt->_detect('i-tay')},{},'_detect irregular i-tay');
  is_deeply( {$lt->_detect('i-tsu')},{},'_detect irregular i-tsu');
  is_deeply( {$lt->_detect('sgn-BE-FR')},{},'_detect irregular sgn-BE-FR');
  is_deeply( {$lt->_detect('sgn-BE-NL')},{},'_detect irregular sgn-BE-NL');
  is_deeply( {$lt->_detect('sgn-CH-DE')},{},'_detect irregular sgn-CH-DE');
};

#RFC 'grandfather' : is this still irregular ?
SKIP: {
  skip "Grandfathered tags not [yet] supported",1;
  is_deeply( {$lt->_detect('i-ami')},{},'_detect grandfather i-ami');
};

#RFC 'private'
SKIP: {
  skip "Private tags not [yet] supported",3;
  is_deeply( {$lt->_detect('en-x-US')},{},'_detect private en-x-US');
  is_deeply( {$lt->_detect('el-x-koine')},{},'_detect private en-x-koine');
  is_deeply( {$lt->_detect('el-x-attic')},{},'_detect private en-x-attic');
};

# RFC 'regular'
is_deeply( {$lt->_detect('en-Latn')},{'iso639_1'=>'en','iso15924'=>'Latn'},'_detect en-Latn');
SKIP: {
  skip "Regular tags that are failing in this push",9;
  is_deeply( {$lt->_detect('art-lojban')},{'iso639_2'=>'art','variant'=>'lojban'},'_detect art-lojban'); # TODO : check
  is_deeply( {$lt->_detect('cel-gaulish')},{'iso639_2'=>'cel','variant'=>'gaulish'},'_detect cel-gaulish');
  is_deeply( {$lt->_detect('no-bok')},{'iso639_1'=>'no','variant'=>'bok'},'_detect no-bok'); # TODO : check
  is_deeply( {$lt->_detect('no-nyn')},{'iso639_1' =>'no','variant'=>'nyn'},'_detect no-nyn'); # TODO : check
  is_deeply( {$lt->_detect('zh-guoyu')},{'iso639_1' =>'zh','variant'=>''},'_detect zh-guoyu'); # TODO : check
  is_deeply( {$lt->_detect('zh-hakka')},{'iso639_1' =>'zh','variant'=>''},'_detect zh-hakka'); # TODO : check
  is_deeply( {$lt->_detect('zh-min')},{'iso639_1' =>'zh','variant'=>''},'_detect zh-min'); # TODO : check
  is_deeply( {$lt->_detect('zh-min-nan')},{'iso639_1' =>'zh','variant'=>''},'_detect zh-min-nan'); # TODO : check
  is_deeply( {$lt->_detect('zh-xiang')},{'iso639_1' =>'zh','variant'=>''},'_detect zh-xiang'); # TODO : check
};

################################################################################

# Test Autodetect
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

################################################################################

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