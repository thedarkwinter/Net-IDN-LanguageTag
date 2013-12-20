package Net::IDN::LanguageTag;

=pod

=head1 NAME

Net::IDN::LanguageTag - Tool to convert between different LanguageTag systems poorly based in RFC5646

=head1 SYNOPSIS

  my $lt;
  $lt = Net::IDN::LanguageTag->new('en'); # auto_detect
  $lt->_from_iso639_1('en'); # call internal method
  print $lt->iso639_2(); # get value
  print $lt->language_name(); # human readable

  $lt->parse('en-GB-Latn'); # slightly longer

=head1 DESCRIPTION

The author was too lazy to write a description.

=cut

use 5.010;
use strict;
use warnings;
use Locale::Language;
use Locale::Country;
use Locale::Script;
use Data::Dumper;

our $VERSION = '0.06';

=pod

=head1 ACCESSORS

=head3 iso639_1()

=head3 iso639_2()

=head3 iso3166_1()

=head3 iso15924()

=head3 iso15924_numeric()

=head3 language_name()

=head3 region_name()

=head3 script_name()

=head3 variant()

=head3 is_grandfather()

=head3 is_private()

=cut

use base qw/Class::Accessor/;
our @ATTRS=qw(is_grandfather is_private);
our @FORMATS=qw(iso3166_1 iso639_1 iso639_2 iso15924 iso15924_numeric extlang variant language_name region_name script_name);
__PACKAGE__->mk_accessors((@ATTRS,@FORMATS));

################################################################################
=pod 

=head3 ALIASES

=head3 iso639() = detect iso639_1 or 2, default is 1

=head3 language() = iso639

=head3 region() = iso3166_1

=head3 script() = iso15924

=cut

sub iso639 { 
  my ($self,$c) = @_; 
  if (!defined $c) { return $self->iso639_1(); }
  return (length($c) == 2) ? $self->iso639_1($c) : $self->iso639_2($c);
}
sub language { my $self = shift; return $self->iso639(@_);  }
sub region { my $self = shift; return $self->iso3166_1(@_) ; }
sub script { my $self = shift; return $self->iso15924(@_); }

################################################################################
=pod

=head1 PUBLIC METHODS

=head2 new()

Create a new LanguageTag object and optionionally pass a language tag string to automically parse it.

  my $lt = Net::IDN::LanguageTag->new('eng-Cyrl');

=head2 parse()

Parse a RFC5646 string

  $lt->parse('en-GB');
  
=head2 reset()

Reset (undef) all accessors. You probably won't need to call it as its done automically on parse()

  $lt->reset(); 
  
=cut

sub new {
	my ($class,$lt) = @_;
	my $self  = bless {  }, $class;
	$self->parse($lt) if $lt;
	return $self;
}

sub parse {
	my ($self,$lt) = @_;
	$self->reset();
	my %h = $self->_detect($lt);
	
#	print Dumper \%h;
	
	foreach my $f (keys %h)
	{
    $self->_from($f,$h{$f});
    $self->variant($h{$f}) if $f eq 'variant';
  }
	return;
}

# reset all values
sub reset {
	my $self = shift;
	our (@ATTRS,@FORMATS);
	foreach ((@ATTRS,@FORMATS)) {
		$self->$_(undef);
	}
	return;
}

################################################################################
=pod

=head1 PRIVATE METHODS

In most cases, you should not need to call these, but be my guest.

=head2 _detect()

Detects what format the string is in, and returns a hash of format => value after splitting it.

  %h = $lt->_detect('eng-Latn'); # ( 'iso639_1' => 'en', 'iso15924' => 'Latn')

=cut

sub _detect {
  my ($self,$v) = @_;
  my (%h,$f);

  # single (no hyphen)
  if ($v =~ m/^[a-z]{2,3}$/) { %h = ('iso639'=>$v); }
  elsif ($v =~ m/^[A-Z]{2}$/) { %h = ('iso3166_1' => $v); }
  elsif ($v =~ m/^[A-Z][a-z]{3}$/)  { %h = ('iso15924' => $v); }
  elsif ($v =~ m/^[\d]{3}$/)  { %h = ('iso15924_numeric' => $v); }
  
  # language-extlang-region-script-variant
  elsif ($v =~ m/^([a-z]{2,3})-([a-z]{2,8})-([A-Z]{2})-([A-Z][a-z]{3})-([a-z]+)$/) { %h = ('iso639'=>$1,'extlang'=>$2,'iso3166_1'=>$3,'iso15924'=>$4,'variant'=>$5); }
  elsif ($v =~ m/^([a-z]{2,3})-([a-z]{2,8})-([A-Z]{2})-([A-Z][a-z]{3})+$/) { %h = ('iso639'=>$1,'extlang'=>$2,'iso3166_1'=>$3,'iso15924'=>$4); }
  elsif ($v =~ m/^([a-z]{2,3})-([a-z]{2,8})-([A-Z]{2})+$/) { %h = ('iso639'=>$1,'extlang'=>$2,'iso3166_1'=>$3); }
  elsif ($v =~ m/^([a-z]{2,3})-([a-z]{2,8})+$/) { %h = ('iso639'=>$1,'extlang'=>$2); }

  # language-extlang-script-variant
  elsif ($v =~ m/^([a-z]{2,3})-([a-z]{2,8})-([A-Z][a-z]{3})-([a-z]+)$/) { %h = ('iso639'=>$1,'extlang'=>$2,'iso15924'=>$3,'variant'=>$4); }
  elsif ($v =~ m/^([a-z]{2,3})-([a-z]{2,8})-([A-Z][a-z]{3})$/) { %h = ('iso639'=>$1,'extlang'=>$2,'iso15924'=>$3); }
  elsif ($v =~ m/^([a-z]{2,3})-([a-z]{2,8})$/) { %h = ('iso639'=>$1,'extlang'=>$2); }

  # language-extlang-variant
  elsif ($v =~ m/^([a-z]{2,3})-([a-z]{2,8})-([a-z]+)$/) { %h = ('iso639'=>$1,'extlang'=>$2,'variant'=>$3); }

  #language-region-script-variant
  elsif ($v =~ m/^([a-z]{2,3})-([A-Z]{2})-([A-Z][a-z]{3})-([a-z]+)$/)  { %h = ('iso639'=>$1,'iso3166_1'=>$2,'iso15924'=>$3,'variant'=>$4); }
  elsif ($v =~ m/^([a-z]{2,3})-([A-Z]{2})-([A-Z][a-z]{3})$/)  { %h = ('iso639'=>$1,'iso3166_1'=>$2,'iso15924'=>$3); }
  elsif ($v =~ m/^([a-z]{2,3})-([A-Z]{2})$/)  { %h = ('iso639'=>$1,'iso3166_1'=>$2); }

  #language-script-variant
  elsif ($v =~ m/^([a-z]{2,3})-([A-Z][a-z]{3})-([a-z]+)?$/)  { %h = ('iso639'=>$1,'iso15924'=>$2,'variant'=>$3); }
  elsif ($v =~ m/^([a-z]{2,3})-([A-Z][a-z]{3})?$/)  { %h = ('iso639'=>$1,'iso15924'=>$2); }

  #language-variant
  elsif ($v =~ m/^([a-z]{2,3})-([a-z]+)?$/)  {  %h = ('iso639'=>$1,'variant'=>$2); }

  #plain text
  elsif ($v =~ m/^[A-Za-z]+$/) { 
    %h = ( 'language_name'  => $v) if $self->_is('language_name',$v);
    %h = ( 'region_name'  => $v) if $self->_is('region_name',$v);
    %h = ( 'script_name'  => $v) if $self->_is('script_name',$v);
   }

  # convert to correct iso639
  if (exists $h{iso639}) {
    $h{iso639_1} = $h{iso639} if length($h{iso639}) ==2;
    $h{iso639_2} = $h{iso639} if length($h{iso639}) ==3;
    delete $h{iso639};
  }
 #print Dumper \%h;

  return %h;
}

################################################################################
=pod

=head2 _is()

Dispatcher to check if a string is <format>

  print "yes it is" if $lr->_is('iso639_1','en');

=cut

our $is_dispatch = { 
        'iso639_1' => sub { return ( $_[0] =~ m/^[a-z]{2}$/ && code2language($_[0],LOCALE_LANG_ALPHA_2) ) ? 1 : undef; },
        'iso639_2' => sub { return ( $_[0] =~ m/^[a-z]{3}$/ && code2language($_[0],LOCALE_LANG_ALPHA_3) ) ? 1 : undef; },
        'iso3166_1' => sub { return ( $_[0] =~ m/^[A-Z]{2}$/ && code2country($_[0],LOCALE_CODE_ALPHA_2) ) ? 1 : undef; },
        'iso15924' => sub { return ( ($_[0] =~ m/^[A-Z][a-z]{3}$/ && code2script($_[0],LOCALE_SCRIPT_ALPHA)) || ($_[0] =~ m/^\d{3}$/ && code2script($_[0],LOCALE_SCRIPT_NUMERIC)) ) ? 1 : undef; },

        'language' => sub { return ( ( $_[0] =~ m/^[a-z]{2}$/ && code2language($_[0],LOCALE_LANG_ALPHA_2) ) ||  ( $_[0] =~ m/^[a-z]{3}$/ && code2language($_[0],LOCALE_LANG_ALPHA_3) ) )? 1 : undef; },
        'iso639' => sub { return ( ( $_[0] =~ m/^[a-z]{2}$/ && code2language($_[0],LOCALE_LANG_ALPHA_2) ) ||  ( $_[0] =~ m/^[a-z]{3}$/ && code2language($_[0],LOCALE_LANG_ALPHA_3) ) )? 1 : undef; },
        'region' => sub { return ( $_[0] =~ m/^[A-Z]{2}$/ && code2country($_[0],LOCALE_CODE_ALPHA_2) ) ? 1 : undef; },
        'script' => sub {  return ( $_[0] =~ m/^[A-Z][a-z]{3}$/ && code2script($_[0],LOCALE_LANG_ALPHA_2) ) ? 1 : undef; },

        'language_name' => sub { return ( $_[0] =~ m/^\w{3,}$/ && language2code($_[0]) ) ? 1 : undef; },
        'region_name' => sub { return ( $_[0] =~ m/^\w{3,}$/ && country2code($_[0]) ) ? 1 : undef; },
        'script_name' => sub {  return ( $_[0] =~ m/^\w{3,}$/ && script2code($_[0]) ) ? 1 : undef; },
    };

sub _is {
  my ($self,$format,$what) = @_;
  our ($is_dispatch);
  return (exists $is_dispatch->{$format}) ? $is_dispatch->{$format}->($what) : undef;
}

################################################################################
=pod

=head2  _from()

Dispatcher to convert to everythong possible from <format>

  $lt->from('iso639_1','en');
  
You can also call the methods direct

=head3 _from_iso639()

=head3 _from_iso639_1()

=head3 _from_iso639_2()

=head3 _from_iso3166_1()

=head3 _from_iso15924()

=head3 _from_language_name()

=head3 _from_region_name()

=head3 _from_script_name()

=cut

our $from_dispatch = {
      'iso639_1' => \&_from_iso639_1,
      'iso639_2' => \&_from_iso639_2,
      'iso3166_1' => \&_from_iso3166_1,
      'iso15924' => \&_from_iso15924,
      'iso15924_numeric' => \&_from_iso15924_numeric,
      'language' => \&_from_iso639,
      'region' => \&_from_iso3166_1,
      'script' => \&_from_iso15924,
      'language_name' => \&_from_language_name,
      'region_name' => \&_from_region_name,
      'script_name' => \&_from_script_name,
  };

sub _from {
  my ($self,$format,$what) = @_;
  our ($from_dispatch);
  return (exists $from_dispatch->{$format}) ? $from_dispatch->{$format}->($self,$what) : undef;
}

sub _from_iso639
{
  my ($self,$c) = @_;
  return (length($c)==2) ? $self->_from_iso639_1($c) : $self->_from_iso639_2($c);
}

sub _from_iso639_1
{
  my ($self,$c) = @_;
  return unless $self->_is('iso639_1',$c);
  $self->iso639_1(lc($c));
  $self->iso639_2(language_code2code($c,LOCALE_LANG_ALPHA_2,LOCALE_LANG_ALPHA_3));
  $self->language_name(code2language($c,LOCALE_LANG_ALPHA_2));
  return;
}

sub _from_iso639_2
{
  my ($self,$c) = @_;
  return unless $self->_is('iso639_2',$c);
  $self->iso639_2(lc($c));
  $self->iso639_1(language_code2code($c,LOCALE_LANG_ALPHA_3,LOCALE_LANG_ALPHA_2));
  $self->language_name(code2language($c,LOCALE_LANG_ALPHA_3));
  return;
}

sub _from_iso3166_1
{
  my ($self,$c) = @_;
  return unless $self->_is('iso3166_1',$c);
  $self->iso3166_1(uc($c));
  $self->region_name(code2country($c,LOCALE_CODE_ALPHA_2));
  return;
}

sub _from_iso15924_numeric { my $self = shift; return $self->_from_iso15924(@_); }
sub _from_iso15924
{
  my ($self,$c) = @_;
  return unless $self->_is('iso15924',$c);
  if ($c =~ m/^\w{4}$/)
  {
    $self->iso15924($c);
    $self->iso15924_numeric(script_code2code($c,LOCALE_SCRIPT_ALPHA,LOCALE_SCRIPT_NUMERIC));
  } elsif ($c =~ m/^\d{3}$/)
  {
     $self->iso15924_numeric($c);
     $self->iso15924(script_code2code($c,LOCALE_SCRIPT_NUMERIC,LOCALE_SCRIPT_ALPHA));
  }
  $self->script_name(code2script($self->iso15924()));
  return;
}

sub _from_language { my $self = shift; return $self->_from_iso639(@_); }
sub _from_language_name
{
  my ($self,$c) = @_;
  return unless $self->_is('language_name',$c);
  $self->iso639_1(language2code($c));
  $self->iso639_2(language_code2code($self->iso639_1(),LOCALE_LANG_ALPHA_2,LOCALE_LANG_ALPHA_3));
  $self->language_name($c);
  return;
}

sub _from_region { my $self = shift; return $self->_from_iso3166_1(@_); }
sub _from_region_name
{
  my ($self,$c) = @_;
  return unless $self->_is('region_name',$c);
  $self->iso3166_1(country2code($c));
  $self->region_name($c);
  return;
}

sub _from_script { my $self = shift; return $self->_from_iso15924(@_); }
sub _from_script_name
{
  my ($self,$c) = @_;
  return unless $self->_is('script_name',$c);
  $self->iso15924(script2code($c));
  $self->iso15924_numeric(script_code2code($self->iso15924(),LOCALE_SCRIPT_ALPHA,LOCALE_SCRIPT_NUMERIC));
  $self->script_name($c);
  return;
}

1;

=pod

=head1 AUTHOR

Copyright 2013 Michael Holloway <michael@thedarkwinter.com>

=head1 LICENSE

The Artistic License 2.0

=cut