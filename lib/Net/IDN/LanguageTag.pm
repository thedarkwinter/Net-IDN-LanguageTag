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

=cut

use 5.010;
use strict;
use warnings;
use Locale::Language;
use Locale::Script;

use base qw/Class::Accessor/;
our @FORMATS=qw(language iso639_1 iso639_2 iso15924 iso15924_numeric);
__PACKAGE__->mk_accessors(@FORMATS);

our $VERSION = '0.01';

sub new {
	my ($class,$lt) = @_;
	my $self  = bless {  }, $class;
	$self->parse($lt) if $lt;
	return $self;
}

sub parse {
	my ($self,$lt) = @_;
	$self->_reset();
  return 1 if $lt =~ m/^\w{2}$/ && $self->_from_iso639_1($lt); 
  return 1 if $lt =~ m/^\w{3}$/ && $self->_from_iso639_2($lt);
  return 1 if $lt =~ m/^(\w{4}|\d{3})$/ && $self->_from_iso15924($lt);
	return 1 if $lt =~ m/^\w{4,}$/ &&  $self->_from_language($lt);
	return undef;
}

sub _reset {
	my $self = shift;
	our (@FORMATS);
	foreach (@FORMATS) {
		$self->$_(undef);
	}
	return;
}

sub _from_iso639_1
{
  my ($self,$c) = @_;
  return unless code2language($c,LOCALE_LANG_ALPHA_2);
  $self->iso639_1($c);
  $self->iso639_2(language_code2code($c,LOCALE_LANG_ALPHA_2,LOCALE_LANG_ALPHA_3));
  $self->language(code2language($c,LOCALE_LANG_ALPHA_2));
  return;
}

sub _from_iso639_2
{
  my ($self,$c) = @_;
  return unless code2language($c,LOCALE_LANG_ALPHA_3);
  $self->iso639_2($c);
  $self->iso639_1(language_code2code($c,LOCALE_LANG_ALPHA_3,LOCALE_LANG_ALPHA_2));
  $self->language(code2language($c,LOCALE_LANG_ALPHA_3));
  return;
}

sub _from_iso15924
{
  my ($self,$c) = @_;
  if ($c =~ m/^\w{4}$/)
  {
    return unless code2script($c,LOCALE_SCRIPT_ALPHA);
    $self->iso15924($c);
    $self->iso15924_numeric(script_code2code($c,LOCALE_SCRIPT_ALPHA,LOCALE_SCRIPT_NUMERIC));
  } elsif ($c =~ m/^\d{3}$/)
  {
     return unless code2script($c,LOCALE_SCRIPT_NUMERIC);
     $self->iso15924_numeric($c);
     $self->iso15924(script_code2code($c,LOCALE_SCRIPT_NUMERIC,LOCALE_SCRIPT_ALPHA));
  }
  return;
}

sub _from_language
{
  my ($self,$c) = @_;
  return unless language2code($c);
  $self->iso639_1(language2code($c));
  $self->iso639_2(language_code2code($self->iso639_1(),LOCALE_LANG_ALPHA_2,LOCALE_LANG_ALPHA_3));
  $self->language($c);
  return;
}


1;

=pod

=head1 SUPPORT

No support is available

=head1 AUTHOR

Copyright 2012 Anonymous.

=cut
