package Net::IDN::LanguageTag;

=pod

=head1 NAME

Net::IDN::LanguageTag - Tool to convert between different LanguageTag systems poorly based in RFC 5646

=head1 SYNOPSIS

	my $lt;
  $lt = Net::IDN::LanguageTag->new(iso639_1  => 'en' ); # define input
  $lt = Net::IDN::LanguageTag->new('en' ); # auto_detect
  $lt->_from('iso639_1','en'); # call internal method
  $lt->iso639_2() # get value

=head1 DESCRIPTION

The author was too lazy to write a description.

=head1 METHODS

Accessors: language iso639_1 iso639_2 iso15924 iso15924_numeric

=cut

use 5.010;
use strict;
use warnings;
use Locale::Language;
use Locale::Country;
use Locale::Script;
use Data::Dumper;


use base qw/Class::Accessor/;
our @FORMATS=qw(country language variant is_grandfather is_private iso3166_1 iso639_1 iso639_2 iso15924 iso15924_numeric);
__PACKAGE__->mk_accessors(@FORMATS);

our $VERSION = '0.03';

################################################################################
### MAIN subs

sub new {
	my ($class,$lt) = @_;
	my $self  = bless {  }, $class;
	$self->parse($lt) if $lt;
	return $self;
}

# reset all values
sub _reset {
	my $self = shift;
	our (@FORMATS);
	foreach (@FORMATS) {
		$self->$_(undef);
	}
	return;
}

sub parse {
	my ($self,$lt) = @_;
	$self->_reset();
	my %h = $self->detect($lt);
#	print Dumper \%h;
	
	foreach my $k (keys %h)
	{
    $self->_from_iso639_1($h{$k}) if $k eq 'iso639_1';
    $self->_from_iso639_2($h{$k}) if $k eq 'iso639_2';
    $self->_from_iso15924($h{$k}) if $k eq 'iso15924';
    $self->_from_iso3166_1($h{$k}) if $k eq 'iso3166_1';
    $self->_from_language($h{$k}) if $k eq 'language';
    $self->_from_country($h{$k}) if $k eq 'country';
    $self->variant($h{$k}) if $k eq 'variant';
  }
	return;
}

sub parse_hash {
  my ($self,%h) = @_;

   return;
}


sub detect {
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
    return ( 'iso639_1' => $v1, 'iso3166-1' => $v2, 'variant' => $v3) if $self->_is_iso639_1($v1) && $self->_is_iso3166_1($v2) && $v3 =~ /^\w+$/; # en-GB-cockney ??
    return ( 'iso639_2' => $v2, 'iso3166-1' => $v2, 'variant' => $v3) if $self->_is_iso639_1($v1) && $self->_is_iso3166_1($v2) && $v3 =~ /^\w+$/; # eng-GB-cockney ??
  } elsif ($v2) # two parts
  {
    return ( 'iso639_1' => $v1, 'iso3166-1' => $v2) if $self->_is_iso639_1($v1) && $self->_is_iso3166_1($v2); # en-GB
    return ( 'iso639_2' => $v1, 'iso3166-1' => $v2) if $self->_is_iso639_2($v1) && $self->_is_iso3166_1($v2); # eng-GB
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
  }
  return;
}

################################################################################
### IS subs
sub _is_iso639_1 { return ( $_[1] =~ m/^\w{2}$/ && code2language($_[1],LOCALE_LANG_ALPHA_2) ) ? 1 : undef; }
sub _is_iso639_2 { return ( $_[1] =~ m/^\w{3}$/ && code2language($_[1],LOCALE_LANG_ALPHA_3) ) ? 1 : undef; }
sub _is_iso3166_1 { return ( $_[1] =~ m/^\w{2}$/ && code2country($_[1],LOCALE_CODE_ALPHA_2) ) ? 1 : undef; }
sub _is_iso15924 { return ( ($_[1] =~ m/^\w{4}$/ && code2script($_[1],LOCALE_SCRIPT_ALPHA)) || ($_[1] =~ m/^\d{3}$/ && code2script($_[1],LOCALE_SCRIPT_NUMERIC)) ) ? 1 : undef; }

sub _is_language { return ( $_[1] =~ m/^\w{3,}$/ && language2code($_[1]) ) ? 1 : undef; }
sub _is_country { return ( $_[1] =~ m/^\w{3,}$/ && country2code($_[1]) ) ? 1 : undef; }

################################################################################
### FROM subs
sub _from_iso639_1
{
  my ($self,$c) = @_;
  return unless $self->_is_iso639_1($c);
  $self->iso639_1($c);
  $self->iso639_2(language_code2code($c,LOCALE_LANG_ALPHA_2,LOCALE_LANG_ALPHA_3));
  $self->language(code2language($c,LOCALE_LANG_ALPHA_2));
  return;
}

sub _from_iso639_2
{
  my ($self,$c) = @_;
  return unless $self->_is_iso639_2($c);
  $self->iso639_2($c);
  $self->iso639_1(language_code2code($c,LOCALE_LANG_ALPHA_3,LOCALE_LANG_ALPHA_2));
  $self->language(code2language($c,LOCALE_LANG_ALPHA_3));
  return;
}

sub _from_iso3166_1
{
  my ($self,$c) = @_;
  return unless $self->_is_iso3166_1($c);
  $self->iso3166_1($c);
  $self->country(code2country($c,LOCALE_CODE_ALPHA_2));
  return;
}

sub _from_iso15924
{
  my ($self,$c) = @_;
  return unless $self->_is_iso15924($c);
  if ($c =~ m/^\w{4}$/)
  {
    $self->iso15924($c);
    $self->iso15924_numeric(script_code2code($c,LOCALE_SCRIPT_ALPHA,LOCALE_SCRIPT_NUMERIC));
  } elsif ($c =~ m/^\d{3}$/)
  {
     $self->iso15924_numeric($c);
     $self->iso15924(script_code2code($c,LOCALE_SCRIPT_NUMERIC,LOCALE_SCRIPT_ALPHA));
  }
  return;
}

sub _from_language
{
  my ($self,$c) = @_;
  return unless $self->_is_language($c);
  $self->iso639_1(language2code($c));
  $self->iso639_2(language_code2code($self->iso639_1(),LOCALE_LANG_ALPHA_2,LOCALE_LANG_ALPHA_3));
  $self->language($c);
  return;
}

sub _from_country
{
  my ($self,$c) = @_;
  return unless $self->_is_country($c);
  $self->iso3166_1(country2code($c));
  $self->country($c);
  return;
}


1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Anonymous.

=cut
