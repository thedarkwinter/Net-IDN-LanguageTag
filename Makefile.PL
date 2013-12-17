use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'Net::IDN::LanguageTag',
    VERSION_FROM    => 'lib/Net/IDN/LanguageTag.pm',
    AUTHOR          => 'Michael Holloway <michael@thedarkwinter.com>',
    PREREQ_PM       => { 'Class::Accessor'=>0, 'Locale::Language'=>0, 'Locale::Script'=>0 },
    dist            => { COMPRESS => 'gzip', SUFFIX => '.gz', },
);
