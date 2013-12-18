package Net::IDN::LanguageTag;

=pod

=head1 NAME

Net::IDN::LanguageTag - Tool to convert between different LanguageTag systems poorly based in RFC5646

=head1 SYNOPSIS

  my $lt;
  $lt = Net::IDN::LanguageTag->new('en'); # auto_detect
  $lt->_from_iso639_1('en'); # call internal method
  $lt->iso639_2() # get value

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 ACCESSORS

=head3 iso639_1()

=head3 iso639_2()

=head3 iso3166_1()

=head3 iso15924()

=head3 iso15924_numeric()

=head3 language()

=head3 country()

=head3 script()

=head3 variant()

=head3 is_grandfather()

=head3 is_private()

=cut

use 5.010;
use strict;
use warnings;
use Locale::Language;
use Locale::Country;
use Locale::Script;
use Data::Dumper;


use base qw/Class::Accessor/;
our @ATTRS=qw(is_grandfather is_private);
our @FORMATS=qw(country language script variant iso3166_1 iso639_1 iso639_2 iso15924 iso15924_numeric);
__PACKAGE__->mk_accessors((@ATTRS,@FORMATS));

our $VERSION = '0.04';

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
  our @FORMATS;
  my %h;
  foreach my $s (split '-',$v)
  {
      $self->is_grandfather(1) && next if ($s eq 'i');
      $self->is_private(1) && next if ($s eq 'x');
      foreach my $f (@FORMATS)
      {
        next if exists ($h{$f});
        next if ($f =~ m/^iso639/ && ( exists $h{'iso639_1'} || exists $h{'iso639_2'})); # we assume only one will be used
        $h{$f} = $s if ($self->_is($f,$s));
      }
      ## variants
  }
  return %h;
}

=cut
sub _detect_old {
  my ($self,$v) = @_;

  # Singletons I & X
  if ($v =~ m/^i-/) { # grandfather
    $self->is_grandfather(1);
    # TODO - And now?
  }

  if ($v =~ m/^x-/) { # private
   $self->is_private(1);
   # TODO - And now?
  }

  # logic, split into as many peices as there are by hyphen, and then try and match by the "most likely solution"
  my ($v1,$v2,$v3) = split '-',$v;

  if ($v3) # three parts
  {
    return ( 'iso639_1' => $v1, 'iso3166_1' => $v2, 'variant' => $v3) if $self->_is_iso639_1($v1) && $self->_is_iso3166_1($v2) && $v3 =~ /^\w+$/; # en-GB-cockney ??
    return ( 'iso639_2' => $v2, 'iso3166_1' => $v2, 'variant' => $v3) if $self->_is_iso639_1($v1) && $self->_is_iso3166_1($v2) && $v3 =~ /^\w+$/; # eng-GB-cockney ??
  } elsif ($v2) # two parts
  {
    return ( 'iso639_1' => $v1, 'iso3166_1' => $v2) if $self->_is_iso639_1($v1) && $self->_is_iso3166_1($v2); # en-GB
    return ( 'iso639_2' => $v1, 'iso3166_1' => $v2) if $self->_is_iso639_2($v1) && $self->_is_iso3166_1($v2); # eng-GB
    return ( 'iso639_1' => $v1, 'iso15924' => $v2) if $self->_is_iso639_1($v1) && $self->_is_iso15924($v2); # en-Latn
    return ( 'iso639_2' => $v1, 'iso15924' => $v2) if $self->_is_iso639_2($v1) && $self->_is_iso15924($v2); # eng-Latn
  } else # 1 part
  {
    return ( 'iso639_1' => $v1) if $self->_is_iso639_1($v1);  # en
    return ( 'iso639_2' => $v1 ) if $self->_is_iso639_2($v1);  # eng
    return ( 'iso15924' => $v1 ) if $self->_is_iso15924($v1);  # Latn
    return ( 'iso3166_1' => $v1 ) if $self->_is_iso3166_1($v1);  # GB
    return ( 'language' => $v1 ) if $self->_is_language($v1); # English
    return ( 'country' => $v1 ) if $self->_is_country($v1); # United Kingdom
    return ( 'script' => $v1 ) if $self->_is_script($v1); # Latin
  }
  return;
}
=cut


################################################################################
=pod

=head2 _is()

Dispatcher to check if a string is <format>

  print "yes it is" if $lr->_is('iso639_1','en');

=cut

our $is_dispatch = { 
        'iso639_1' => sub { return ( $_[0] =~ m/^\w{2}$/ && code2language($_[0],LOCALE_LANG_ALPHA_2) ) ? 1 : undef; },
        'iso639_2' => sub { return ( $_[0] =~ m/^\w{3}$/ && code2language($_[0],LOCALE_LANG_ALPHA_3) ) ? 1 : undef; },
        'iso3166_1' => sub { return ( $_[0] =~ m/^\w{2}$/ && code2country($_[0],LOCALE_CODE_ALPHA_2) ) ? 1 : undef; },
        'iso15924' => sub { return ( ($_[0] =~ m/^\w{4}$/ && code2script($_[0],LOCALE_SCRIPT_ALPHA)) || ($_[0] =~ m/^\d{3}$/ && code2script($_[0],LOCALE_SCRIPT_NUMERIC)) ) ? 1 : undef; },

        'language' => sub { return ( $_[0] =~ m/^\w{3,}$/ && language2code($_[0]) ) ? 1 : undef; },
        'country' => sub { return ( $_[0] =~ m/^\w{3,}$/ && country2code($_[0]) ) ? 1 : undef; },
        'script' => sub {  return ( $_[0] =~ m/^\w{3,}$/ && script2code($_[0]) ) ? 1 : undef; },
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

=head3 _from_iso639_1()

=head3 _from_iso639_2()

=head3 _from_iso3166_1()

=head3 _from_iso15924()

=head3 _from_language()

=head3 _from_country()

=head3 _from_script()

=cut

our $from_dispatch = {
      'iso639_1' => \&_from_iso639_1,
      'iso639_2' => \&_from_iso639_2,
      'iso3166_1' => \&_from_iso3166_1,
      'iso15924' => \&_from_iso15924,
      'language' => \&_from_language,
      'country' => \&_from_country,
      'script' => \&_from_script,
  };

sub _from {
  my ($self,$format,$what) = @_;
  our ($from_dispatch);
  return (exists $from_dispatch->{$format}) ? $from_dispatch->{$format}->($self,$what) : undef;
}

sub _from_iso639_1
{
  my ($self,$c) = @_;
  return unless $self->_is('iso639_1',$c);
  $self->iso639_1(lc($c));
  $self->iso639_2(language_code2code($c,LOCALE_LANG_ALPHA_2,LOCALE_LANG_ALPHA_3));
  $self->language(code2language($c,LOCALE_LANG_ALPHA_2));
  return;
}

sub _from_iso639_2
{
  my ($self,$c) = @_;
  return unless $self->_is('iso639_2',$c);
  $self->iso639_2(lc($c));
  $self->iso639_1(language_code2code($c,LOCALE_LANG_ALPHA_3,LOCALE_LANG_ALPHA_2));
  $self->language(code2language($c,LOCALE_LANG_ALPHA_3));
  return;
}

sub _from_iso3166_1
{
  my ($self,$c) = @_;
  return unless $self->_is('iso3166_1',$c);
  $self->iso3166_1(uc($c));
  $self->country(code2country($c,LOCALE_CODE_ALPHA_2));
  return;
}

sub _from_iso15924
{
  my ($self,$c) = @_;
  return unless $self->_is('iso15924',$c);
  if ($c =~ m/^\w{4}$/)
  {
    $self->iso15924($c);
    $self->iso15924_numeric(script_code2code($c,LOCALE_SCRIPT_ALPHA,LOCALE_SCRIPT_NUMERIC));
     $self->script(code2script($self->iso15924()));
  } elsif ($c =~ m/^\d{3}$/)
  {
     $self->iso15924_numeric($c);
     $self->iso15924(script_code2code($c,LOCALE_SCRIPT_NUMERIC,LOCALE_SCRIPT_ALPHA));
     $self->script(code2script($self->iso15924()));
  }
  return;
}

sub _from_language
{
  my ($self,$c) = @_;
  return unless $self->_is('language',$c);
  $self->iso639_1(language2code($c));
  $self->iso639_2(language_code2code($self->iso639_1(),LOCALE_LANG_ALPHA_2,LOCALE_LANG_ALPHA_3));
  $self->language($c);
  return;
}

sub _from_country
{
  my ($self,$c) = @_;
  return unless $self->_is('country',$c);
  $self->iso3166_1(country2code($c));
  $self->country($c);
  return;
}

sub _from_script
{
  my ($self,$c) = @_;
  return unless $self->_is('script',$c);
  $self->iso15924(script2code($c));
  $self->iso15924_numeric(script_code2code($self->iso15924(),LOCALE_SCRIPT_ALPHA,LOCALE_SCRIPT_NUMERIC));
  $self->script($c);
  return;
}

1;

=pod

=head1 AUTHOR

Copyright 2013 Michael Holloway <michael@thedarkwinter.com>

=head1 LICENSE

The Artistic License 2.0

=cut