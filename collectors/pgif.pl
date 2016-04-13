#!/usr/bin/perl
#
# pgif.pl - get name value pairs for gif files.
#
# $Revision: 1.1.1.1 $
#
# $Log: pgif.pl,v $
# Revision 1.1.1.1  2005/12/05 15:06:11  bill
# Imported sources
#
# Revision 1.1.1.1  2005/08/24 17:13:15  howew
# Quarry
#
# Revision 1.1.1.1  2005/08/17 19:12:41  howew
# Quarry Source
#
# Revision 1.1  2004/03/09 23:24:47  bill
#
# colection script teste with new version of reflect
#
# Revision 1.3  2004/03/09 23:05:22  kuldeep
# Handles Unknown Values. Doesn't call Addiem on unknown Values
#
# Revision 1.2  2004/02/21 00:13:39  bill
#
# Upkeep test: ForecastRnId -> RunId
#
# Revision 1.1.1.1  2003/12/09 00:04:02  kuldeep
# Reflect metadata collection
#
# Revision 1.5  2003/08/22 22:44:50  pturner
#
# Fixed buglet.
#
# Revision 1.4  2003/08/22 22:42:33  pturner
#
# Added a couple of comments.
#
# Revision 1.3  2003/08/22 22:40:14  pturner
#
# Perl tidy.
#
# Revision 1.2  2003/08/22 22:38:44  pturner
#
# More additions to table.
#
#

use strict;
use File::Basename;
do 'additem.pl';

my $debug = 1;
my $err   = 0;

if ( scalar @ARGV != 1 ) {
    print "Error: Number of command line arguments is incorrect, must be 1.\n";
    print "Usage: $0 filename\n";
    exit(1);
}

my $filename = $ARGV[0];

if ( !( -e $filename ) ) {
    print "Error: filename does not exist: $filename\n";
    exit(2);
}

my $f;
my $file;
my $path;
my @path;
my $p;
my $ext;
my @info;

my %vals = (
    "Average"          => "Aggregate",
    "ELV"              => "Variable",
    "Elevation"        => "Variable",
    "HVEL"             => "Variable",
    "Maximum"          => "Aggregate",
    "Minimum"          => "Aggregate",
    "SAL"              => "Variable",
    "ST"               => "PlotType",
    "Salinity"         => "Variable",
    "TEM"              => "Variable",
    "U"                => "Variable",
    "V"                => "Variable",
    "VRES12"           => "Variable",
    "VRES24"           => "Variable",
    "Velocity"         => "Variable",
    "W"                => "Variable",
    "WVEL"             => "Variable",
    "across"           => "Transect",
    "am012"            => "Station",
    "am169"            => "Station",
    "amp"              => "PlotType",
    "amt"              => "PlotType",
    "bottom"           => "Aggregate",
    "bw"               => "PlotType",
    "cbnc3"            => "Station",
    "channel"          => "Transect",
    "circular"         => "Transect",
    "coastal"          => "Transect",
    "col"              => "PlotType",
    "compAD4072"       => "InstrumentComparison",
    "compAD4C37"       => "InstrumentComparison",
    "compAD4C49"       => "InstrumentComparison",
    "compCT1448"       => "InstrumentComparison",
    "compCT1451"       => "InstrumentComparison",
    "compCT1452"       => "InstrumentComparison",
    "compCT1454"       => "InstrumentComparison",
    "compCT1458"       => "InstrumentComparison",
    "compCT1459"       => "InstrumentComparison",
    "compCT1460"       => "InstrumentComparison",
    "compCT1461"       => "InstrumentComparison",
    "compCT1462"       => "InstrumentComparison",
    "compCT1464"       => "InstrumentComparison",
    "compCT1516"       => "InstrumentComparison",
    "compCTD272"       => "InstrumentComparison",
    "compCTD389"       => "InstrumentComparison",
    "compCTD397"       => "InstrumentComparison",
    "compCTD398"       => "InstrumentComparison",
    "compCTD399"       => "InstrumentComparison",
    "compCTD401"       => "InstrumentComparison",
    "depth-timeseries" => "PlotType",
    "dif"              => "Variable",
    "dsdma"            => "Station",
    "dsf"              => "Variable",
    "elcirc"           => "",
    "eliot"            => "Station",
    "elv"              => "",
    "estuary"          => "Region",
    "far"              => "Region",
    "grays"            => "Station",
    "green"            => "Station",
    "habitat"          => "PlotType",
    "histogram"        => "PlotType",
    "horse"            => "Station",
    "intrusion"        => "PlotType",
    "krlsn"            => "Station",
    "length"           => "",
    "lhf"              => "Variable",
    "line"             => "",
    "ll"               => "PlotType",
    "loisi"            => "Station",
    "lonw1"            => "Station",
    "lwsck"            => "Station",
    "marsh"            => "Station",
    "mcgrg"            => "Station",
    "meanprofile"      => "PlotType",
    "mixing"           => "PlotType",
    "mottb"            => "Station",
    "nf2c1"            => "Station",
    "nf2c2"            => "Station",
    "nf2c3"            => "Station",
    "nf2c4"            => "Station",
    "nf2c5"            => "Station",
    "nf2c6"            => "Station",
    "nf2c7"            => "Station",
    "nf2c8"            => "Station",
    "ogi01"            => "Station",
    "p24c1"            => "Station",
    "p24c2"            => "Station",
    "p24c3"            => "Station",
    "p24c4"            => "Station",
    "p24c5"            => "Station",
    "p24c6"            => "Station",
    "p24c7"            => "Station",
    "p24c8"            => "Station",
    "plume"            => "Region",
    "prchn"            => "Station",
    "profile"          => "PlotType",
    "quinn"            => "Station",
    "red26"            => "Station",
    "rmsError"         => "",
    "sal"              => "Variable",
    "salAVG"           => "Variable",
    "salMAX"           => "Variable",
    "salMIN"           => "Variable",
    "salt"             => "Variable",
    "sandi"            => "Station",
    "sc169"            => "Station",
    "scbva"            => "Station",
    "scdsd"            => "Station",
    "scept"            => "Station",
    "scest"            => "Station",
    "sclng"            => "Station",
    "scpri"            => "Station",
    "scr26"            => "Station",
    "scrci"            => "Station",
    "scryi"            => "Station",
    "scsan"            => "Station",
    "sctny"            => "Station",
    "sctpt"            => "Station",
    "scwai"            => "Station",
    "scwau"            => "Station",
    "scwdi"            => "Station",
    "seali"            => "Station",
    "shf"              => "",
    "skaw1"            => "Station",
    "snagi"            => "Station",
    "surface"          => "",
    "sveni"            => "Station",
    "tansy"            => "Station",
    "taylr"            => "Station",
    "tem"              => "Variable",
    "temp"             => "Variable",
    "timeseries"       => "",
    "tpoin"            => "Station",
    "transects"        => "",
    "uif"              => "",
    "vanw1"            => "Station",
    "vapw1"            => "Station",
    "vel"              => "Variable",
    "velAVG"           => "Variable",
    "velMAX"           => "Variable",
    "velMIN"           => "Variable",
    "vol"              => "Variable",
    "wauo3"            => "Station",
    "woody"            => "Station",
    "wvel"             => "Variable",
    "wvl"              => "Variable",
    "yacht"            => "Station",
    "yb101"            => "Station",
    "bnvo3"            => "Station",
    "bvao3"            => "Station",
    "camw1"            => "Station",
    "clso3"            => "Station",
    "cnbw1"            => "Station",
    "csbo3"            => "Station",
    "cwbw1"            => "Station",
    "ecbr1"            => "Station",
    "ecbr2"            => "Station",
    "ecbr3"            => "Station",
    "ecbr4"            => "Station",
    "ecbr5"            => "Station",
    "ecbr6"            => "Station",
    "ecbr7"            => "Station",
    "ecbr8"            => "Station",
    "ecbv1"            => "Station",
    "ecbv2"            => "Station",
    "ecbv3"            => "Station",
    "ecbv4"            => "Station",
    "ecbv5"            => "Station",
    "ecbv6"            => "Station",
    "ecbv7"            => "Station",
    "ecbv8"            => "Station",
    "effn1"            => "Station",
    "effn2"            => "Station",
    "effn3"            => "Station",
    "effn4"            => "Station",
    "effn5"            => "Station",
    "effn6"            => "Station",
    "effn7"            => "Station",
    "effn8"            => "Station",
    "effs1"            => "Station",
    "effs2"            => "Station",
    "effs3"            => "Station",
    "effs4"            => "Station",
    "effs5"            => "Station",
    "effs6"            => "Station",
    "effs7"            => "Station",
    "effs8"            => "Station",
    "efon1"            => "Station",
    "efon2"            => "Station",
    "efon3"            => "Station",
    "efon4"            => "Station",
    "efon5"            => "Station",
    "efon6"            => "Station",
    "efon7"            => "Station",
    "efon8"            => "Station",
    "efos1"            => "Station",
    "efos2"            => "Station",
    "efos3"            => "Station",
    "efos4"            => "Station",
    "efos5"            => "Station",
    "efos6"            => "Station",
    "efos7"            => "Station",
    "efos8"            => "Station",
    "elcirc"           => "Model",
    "elel1"            => "Station",
    "elel2"            => "Station",
    "elel3"            => "Station",
    "elel4"            => "Station",
    "elel5"            => "Station",
    "elel6"            => "Station",
    "elel7"            => "Station",
    "elel8"            => "Station",
    "eleu1"            => "Station",
    "eleu2"            => "Station",
    "eleu3"            => "Station",
    "eleu4"            => "Station",
    "eleu5"            => "Station",
    "eleu6"            => "Station",
    "eleu7"            => "Station",
    "eleu8"            => "Station",
    "elv"              => "Variable",
    "encl1"            => "Station",
    "encl2"            => "Station",
    "encl3"            => "Station",
    "encl4"            => "Station",
    "encl5"            => "Station",
    "encl6"            => "Station",
    "encl7"            => "Station",
    "encl8"            => "Station",
    "encu1"            => "Station",
    "encu2"            => "Station",
    "encu3"            => "Station",
    "encu4"            => "Station",
    "encu5"            => "Station",
    "encu6"            => "Station",
    "encu7"            => "Station",
    "encu8"            => "Station",
    "enfn1"            => "Station",
    "enfn2"            => "Station",
    "enfn3"            => "Station",
    "enfn4"            => "Station",
    "enfn5"            => "Station",
    "enfn6"            => "Station",
    "enfn7"            => "Station",
    "enfn8"            => "Station",
    "enfs1"            => "Station",
    "enfs2"            => "Station",
    "enfs3"            => "Station",
    "enfs4"            => "Station",
    "enfs5"            => "Station",
    "enfs6"            => "Station",
    "enfs7"            => "Station",
    "enfs8"            => "Station",
    "eupa1"            => "Station",
    "eupa2"            => "Station",
    "eupa3"            => "Station",
    "eupa4"            => "Station",
    "eupa5"            => "Station",
    "eupa6"            => "Station",
    "eupa7"            => "Station",
    "eupa8"            => "Station",
    "histograms"       => "PlotType",
    "hvel"             => "Variable",
    "images"           => "Directory",
    "isoamp"           => "PlotType",
    "isoamt"           => "PlotType",
    "isodif"           => "PlotType",
    "isodsf"           => "PlotType",
    "isohabitat"       => "PlotType",
    "isosal"           => "PlotType",
    "isoshf"           => "PlotType",
    "isotem"           => "PlotType",
    "isouif"           => "PlotType",
    "isovel"           => "PlotType",
    "isowvl"           => "PlotType",
    "length"           => "PlotType",
    "line"             => "PlotType",
    "moro3"            => "Station",
    "nbd12"            => "Station",
    "nbd22"            => "Station",
    "nbd26"            => "Station",
    "nbd27"            => "Station",
    "nbd29"            => "Station",
    "nbd41"            => "Station",
    "nbd42"            => "Station",
    "nbd50"            => "Station",
    "rmsError"         => "PlotType",
    "shf"              => "UNKNOWN",
    "sm"               => "UNKNOWN",
    "surface"          => "Region",
    "timeseries"       => "PlotType",
    "transects"        => "PlotType",
    "transhvel"        => "PlotType",
    "transsal"         => "PlotType",
    "transtem"         => "PlotType",
    "transwvel"        => "PlotType",
    "uif"              => "UNKNOWN",
    "vncw1"            => "Station",
    "waro3"            => "Station",
    "wilo3"            => "Station",
    "home"             => "Directory",
    "workspace"        => "Directory",
    "local0"           => "Directory",
    "forecasts"        => "Directory",
    "prod"             => "Directory",
    "2d"               => "PlotType",
);

# Split the path into component parts.
( $file, $path, $ext ) = fileparse( $filename, '\..*' );
@info = split ( /_/, $file );
$path =~ s/\// /g;
$path =~ s/\.//;
@path = split ( /[ |_]/g, $path );
my @nvdt;

# Get meaning of path name components.
foreach $p (@path) {
    $p =~ s/\s+//g;
    if ($p) {
        if ( $p =~ /^200/ ) {
            $vals{$p} = "RunID";
        }
        if ( !$vals{$p} ) {
            $vals{$p} = "";
        }
	my $temp = $vals{$p} ;
	if ( $temp ne "" )
	{
		if ($temp ne "UNKNOWN")
		{
        		$nvdt[0] = $temp;
        		$nvdt[1] = $p;
        		$nvdt[2] = "Descr";
        		$nvdt[3] = "string";
       		 	AddItem(@nvdt);
		}
	}
    }
}

# Get meaning of file name components.
foreach $f (@info) {

    #print "Vals: $f $vals{$f}\n";
    if ( $f =~ /^0\d+/ ) {
        $vals{$f} = "TimeStep";
    }
    elsif ( $f =~ /^\d+$/ ) {
        $vals{$f} = "Depth";
    }
    elsif ( $f =~ /^anim/ ) {
        $vals{$f} = "Animation";
    }
    elsif ( $f =~ /^2d$/ ) {
        $vals{$f} = "PlotType";
    }
   my $temp = $vals{$f} ;
   if ( $temp  ne "" && $temp ne "UNKNOWN") 
  {	
    $nvdt[0] = $temp;
    $nvdt[1] = $f;
    $nvdt[2] = "Descr";
    $nvdt[3] = "string";
    AddItem(@nvdt);
  }
  
}
