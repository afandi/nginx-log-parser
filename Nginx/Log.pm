package Nginx::Log;

use strict;
use warnings;

sub new {
	my $Self = {};
	
	bless($Self);
	return $Self;
}

sub GetLines {
	my $Self = shift;
	my $LogFile = shift;
	
	my %Opts = @_;
	
	die "Need LogFile to parse" unless $LogFile;
	
	print "Открываем файл с логами  $LogFile\n";
	my @Log = ();
	open LOG, "<$LogFile";
	@Log = <LOG>;
	close LOG;
	
	if ($Opts{'Filter'} && ref $Opts{'Filter'} eq 'CODE') {
		@Log = grep {&{$Opts{'Filter'}}($_)} @Log;
	}
	
	if ($Opts{Last}) {
		@Log = reverse @Log;
		return @Log[0 .. ($Opts{Last} - 1)]
	}
	return @Log;
	
	
}

1;