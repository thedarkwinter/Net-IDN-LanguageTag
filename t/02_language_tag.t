#!/usr/bin/perl -w

use 5.010;
use strict;
use warnings;
use Test::More tests => 102;
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

## Test the IS_.. alias methods
is($lt->_is('language','en'),1,'_is_language alias valid');
is($lt->_is('region','FR'),1,'_is_region alias valid');
is($lt->_is('script','Latn'),1,'_is_script alias valid');

## Test the IS_..name methods
is($lt->_is('language_name','English'),1,'_is_language_name valid');
is($lt->_is('language_name','Entish'),undef,'_is_language_name invalid');
is($lt->_is('region_name','France'),1,'_is_region_name valid');
is($lt->_is('region_name','Neverland'),undef,'_is_region_name valid');
is($lt->_is('script_name','Cyrillic'),1,'_is_script_name valid');
is($lt->_is('script_name','Squiggles'),undef,'_is_script_name valid');

################################################################################
### Test from _FROM methods

# FROM iso639_1
$lt->reset();
$lt->_from_iso639_1('en');
is($lt->iso639_1(),'en','from iso639_1 -> iso639_1 (same)');
is($lt->iso639_2(),'eng','from iso639_1 -> iso639_2');
is($lt->iso639(),'en','from iso639_1 -> iso639');
is($lt->language(),'en','from iso639_1 -> language');
is($lt->language_name(),'English','from iso639_1 -> language_name');

# FROM iso639_2
$lt->reset();
$lt->_from_iso639_2('eng');
is($lt->iso639_1(),'en','from iso639_2 -> iso639_1');
is($lt->iso639_2(),'eng','from iso639_2 -> iso639_2 (same)');
is($lt->language_name(),'English','from iso639_2 -> language');

# FROM iso3166_1
$lt->reset();
$lt->_from_iso3166_1('GB');
is($lt->iso3166_1(),'GB','from iso3166_1 -> iso3166_1 (same)');
is($lt->region(),'GB','from iso3166_1 -> region');
is($lt->region_name(),'United Kingdom','from iso3166_1 -> region_name');

# FROM iso15924
$lt->reset();
$lt->_from_iso15924('Phnx');
is($lt->iso15924(),'Phnx','from iso15924 -> iso15924 (same)');

# FROM language
$lt->reset();
$lt->_from_language_name('English');
is($lt->iso639_1(),'en','from language_name -> iso639_1');
is($lt->iso639_2(),'eng','from language_name -> iso639_2');
is($lt->language_name(),'English','from language_name -> language_name (same)');

# FROM region
$lt->reset();
$lt->_from_region_name('France');
is($lt->iso3166_1(),'fr','from region_name -> iso3166_1');
is($lt->region_name(),'France','from region_name  -> region_name (same)');

# FROM script
$lt->reset();
$lt->_from_script_name('Cyrillic');
is($lt->iso15924(),'Cyrl','from script_name -> iso15924');
is($lt->iso15924_numeric(),'220','from script_name -> iso15924_numeric');
is($lt->script_name(),'Cyrillic','from script_name -> script_name (same)');

# FROM Aliases
$lt->reset();
$lt->_from_language('en');
is($lt->iso639(),'en','from language alias -> iso639');
$lt->reset();
$lt->_from_region('DE');
is($lt->region_name(),'Germany','from region alias -> region_name');
$lt->reset();
$lt->_from_script('220');
is($lt->iso15924(),'Cyrl','from script alias -> iso15924');

################################################################################
# Test _detect 

is_deeply( {$lt->_detect('fr')},{'iso639_1'=>'fr'},'_detect fr');
is_deeply( {$lt->_detect('FR')},{'iso3166_1'=>'FR'},'_detect FR');
is_deeply( {$lt->_detect('French')},{'language_name'=>'French'},'_detect France');
is_deeply( {$lt->_detect('France')},{'region_name'=>'France'},'_detect France');
is_deeply( {$lt->_detect('Latin')},{'script_name'=>'Latin'},'_detect Latin');
is_deeply( {$lt->_detect('en-GB')},{'iso639_1'=>'en','iso3166_1'=>'GB'},'_detect en-GB');
is_deeply( {$lt->_detect('eng-ZA')},{'iso639_2'=>'eng','iso3166_1'=>'ZA'},'_detect eng-ZA');
is_deeply( {$lt->_detect('eng-Latn')},{'iso639_2'=>'eng','iso15924'=>'Latn'},'_detect eng-Latn');
is_deeply( {$lt->_detect('en-ZA-Latn')},{'iso639_1'=>'en','iso3166_1'=>'ZA','iso15924'=>'Latn'},'_detect en-ZA-Latn');
is_deeply( {$lt->_detect('en-ZA-Latn-joburg')},{'iso639_1'=>'en','iso3166_1'=>'ZA','iso15924'=>'Latn','variant'=>'joburg'},'_detect en-ZA-Latn-joburg');
is_deeply( {$lt->_detect('en-jnb-ZA-Latn-souf')},{'iso639_1'=>'en','extlang' => 'jnb','iso3166_1'=>'ZA','iso15924'=>'Latn','variant'=>'souf'},'_detect en-jnb-ZA-Latn-souf');
is_deeply( {$lt->_detect('en-dur')},{'iso639_1'=>'en','extlang' => 'dur'},'_detect en-dur');


# RFC 'regular'
is_deeply( {$lt->_detect('en-Latn')},{'iso639_1'=>'en','iso15924'=>'Latn'},'_detect en-Latn');
is_deeply( {$lt->_detect('art-lojban')},{'iso639_2'=>'art','extlang'=>'lojban'},'_detect art-lojban'); # TODO : check
is_deeply( {$lt->_detect('cel-gaulish')},{'iso639_2'=>'cel','extlang'=>'gaulish'},'_detect cel-gaulish');
is_deeply( {$lt->_detect('no-bok')},{'iso639_1'=>'no','extlang'=>'bok'},'_detect no-bok'); # TODO : check
is_deeply( {$lt->_detect('no-nyn')},{'iso639_1' =>'no','extlang'=>'nyn'},'_detect no-nyn'); # TODO : check
is_deeply( {$lt->_detect('zh-guoyu')},{'iso639_1' =>'zh','extlang'=>'guoyu'},'_detect zh-guoyu'); # TODO : check
is_deeply( {$lt->_detect('zh-hakka')},{'iso639_1' =>'zh','extlang'=>'hakka'},'_detect zh-hakka'); # TODO : check
is_deeply( {$lt->_detect('zh-min')},{'iso639_1' =>'zh','extlang'=>'min'},'_detect zh-min'); # TODO : check
is_deeply( {$lt->_detect('zh-min-nan')},{'iso639_1' =>'zh','extlang' => 'min', 'variant'=>'nan'},'_detect zh-min-nan'); # TODO : check
is_deeply( {$lt->_detect('zh-xiang')},{'iso639_1' =>'zh','extlang'=>'xiang'},'_detect zh-xiang'); # TODO : check

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