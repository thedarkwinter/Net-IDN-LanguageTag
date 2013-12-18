Net-IDN-LanguageTag
===================

Net-IDN-LanguageTag attemts to automatically parse RFC5646 language tags into a
Class::Accessor object and build as much information as possible. For example, 
if your language tag is en-GB (language-region), the accesssor will contain the
following methods.

$tag = Net::IDN::LanguageTag->new('en-GB'); # new object parses immediately
print $tag->iso639_1(); # en
print $tag->iso639_2(); # eng
print $tag->iso3166_1(); # GB
print $tag->language(); # English
print $tag->country(); # United Kingdom

$tag = Net::IDN::LanguageTag->new('eng-Latn');
print $tag->iso15924(); # Latn
print $tag->script(); # Latin
# ... etc

See: http://tools.ietf.org/html/rfc5646 
