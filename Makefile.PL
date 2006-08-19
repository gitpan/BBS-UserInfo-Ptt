use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'BBS::UserInfo::Ptt',
    AUTHOR              => 'Gea-Suan Lin <gslin@gslin.org>',
    VERSION_FROM        => 'lib/BBS/UserInfo/Ptt.pm',
    ABSTRACT_FROM       => 'lib/BBS/UserInfo/Ptt.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
	'Expect' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'BBS-UserInfo-Ptt-*' },
);
