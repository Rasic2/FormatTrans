#!perl

use strict;
use warnings;
use Getopt::Long;
use MaterialsScript qw(:all);

# specify the directory storing the xsd files (Notice: directory format)
my $dir="C:\\Users\\hui_zhou\\Documents\\Materials Studio Projects\\Example_Files\\Documents\\catalysts\\heterogenous\\";
my $export_dir="C:\\Users\\hui_zhou\\Desktop\\Structures\\catalysts\\heterogenous\\";

opendir (DIR, $dir) or die "can't open the directory!";
my @dir = readdir DIR;

foreach my $file (@dir) 
{
	if ($file =~ /\.xsd/)
	{
		print "$file \n";
		my $prefix = $file;
		$prefix =~ s/\.xsd//; # remove the extension of the file
		my $doc = $Documents{"heterogenous\\$file"}; # search xsd files under heterogenous directory (Notice: directory format)
		
		$doc->MakeP1; # Make P1
		
		my $lattice=$doc->Lattice3D;
		$lattice->Color=16724923; # set lattice `color=purple`
		
		my $atoms=$doc->UnitCell->Atoms;
		$doc->CalculateBonds;
		foreach my $atom (@$atoms)
		{
			$atom->Style = "Ball and stick"; # set `ball and stick` style
		}
  		$doc->Save;
		$doc->Export("$export_dir\\${prefix}.msi"); # export as *.msi files
  		$doc->Close;
	}
}
