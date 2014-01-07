Net-IDN-LanguageTag
===================

Net-IDN-LanguageTag attemts to automatically parse RFC5646 language tags into a
Class::Accessor object and build as much information as possible. For example, 
if your language tag is en-GB (language-region), the accesssor will contain the
following methods.

```perl
$tag = Net::IDN::LanguageTag->new('en-GB-Latn'); # new object parses immediately  
print $tag->language(); # en  
print $tag->region(); # GB
print $tag->script(); # Latn  

# using ISO names
print $tag->iso639_1(); #  en  
print $tag->iso639_2(); # eng  
print $tag->iso3166_1(); # GB  
print $tag->iso15924(); # Latn

# human readable  
print $tag->language_name(); # English  
print $tag->region_name(); # United Kingdom  
print $tag->script_name(); # Latin   
```
See: http://tools.ietf.org/html/rfc5646 
