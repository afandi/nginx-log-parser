package Nginx::Log::Parser;

use strict;
use warnings;

sub new {
	my $Self = {};
	
	bless($Self);
	$Self->LogFormat('$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"');
	return $Self;
}

sub LogFormat {
	my ($Self, $LogFormat) = @_;
	$Self->{LogFormat} = $LogFormat;
	$Self->GetFields();
	$Self->PrepareRE();
	return $Self->{LogFormat};
}

sub PrepareRE {
	my $Self = shift;
	$Self->{'RE'} = $Self->{'LogFormat'};
	$Self->{'RE'} = quotemeta $Self->{'RE'};
	$Self->{'RE'} =~ s/\\\$\w*/\(\.\*\?\)/g;
}

sub GetFields {
	my $Self = shift;
	@{$Self->{'_Fields'}} = $Self->{LogFormat} =~ /\$(\w*)/g;
}

sub Parse {
	my $Self = shift;
	my $Line = shift;
	my %Opts = @_;
	chomp $Line;
	$Self->PrepareRE unless $Self->{'RE'};
	$Self->GetFields unless $Self->{'_Fields'};
	
	my @Result = $Line =~ /$Self->{'RE'}/;
	my $idx = 0;
	my %Entry = map {$_, $Result[$idx++]} @{$Self->{'_Fields'}};
	if ($Opts{'Func'} && ref $Opts{'Func'} eq 'CODE') {
		&{$Opts{'Func'}}(\%Entry);
	}
	return wantarray ? %Entry : { %Entry };
}

1;