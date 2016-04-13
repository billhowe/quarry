#!/usr/bin/perl
#use strict;                        # important pragma
#use warnings;                      # another important pragma
do 'additem.pl' ;

my @rows;			#An array of rows to be inserted
my $indx = 0;			#Array index for 1st dimmension
my $str;			#Used for parsing
my @names;			#Used for passing name values
my $SINGLE_SPACE = 1;		#Used for single spaced name-values
my $MULTI_SPACE = 0;		#Used for single spaced name-values
my $NL = "\n";			#A newline character

$paramFile = '<' .  $ARGV[0] ; # Open for input
PParser($paramFile); 	#Whole Path of file

sub PParser {
my($pfile) = @_;	 	# $pfile = Parameter file with whole path
my @tmpLine;			#A temporary storage of the param and value
my @tmpLastLine;		#A temporary storage for the last pair
@nvdt = {'a','b','c','d'} ;
open (pHandle,$pfile) || die ("Unable to open $pfile \n") ;
#Get Version
	$nvdt[0] = 'Version'; 
	$nvdt[1] = <pHandle>; 		# read one line of text from parameter file !
	chomp($nvdt[1]) ;
	$nvdt[2] = "48 bit version" ;
	$nvdt[3] = "string" ;
	AddItem (@nvdt) ;

# Get Start Time
	$nvdt[0] = "StartTime";
	$nvdt[1] = <pHandle>;
	chomp ($nvdt[1]) ;
	$nvdt[2] = "48 bit start time" ;
	$nvdt[3] = "string" ;
	AddItem (@nvdt) ;

# Get ipre
	$str = <pHandle>;			# Read next line from Parameter file
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "pre processing flag" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;


# Get nscreen
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "screen on/off switch" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get forecast
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Not given in Manual" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get ihot
	$str = <pHandle>;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Hot start Flag" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get ics
	$str = <pHandle>;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Coordinate Frame Flag" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

#Get slam0, sfea0
	
	$d = "center of projection used to convert lat long to cartesian" ;
	$str = <pHandle>;
	chomp($str) ;

	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "slam0" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = $d ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "sfea0" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = $d ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;
	
#Get implicitness
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "implicitness paramter" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

#Get ibcc, ibtp
	@names = ("ibcc", "ibtp"); 
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "ibcc" ;
	$nvdt[1] = $tmpLine[0] ;
	$ibcc = $nvdt[1] ;
	$nvdt[2] = "Barotropic Flag" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "ibtp" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = "Baroclinic Flag" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;
	
#**** It is unknown if this next line is always here if ibcc != 0
#Get nrampbc, drampbc
	if ($ibcc eq  "0")
	{	
		@names = ("nrampbc", "drampbc"); 
		$str = <pHandle>;
		chomp($str) ;
		@tmpLine = split (/\s/,$str) ;
		$nvdt[0] = "nrampbc" ;
		$nvdt[1] = $tmpLine[0] ;
		$nvdt[2] = "Ramp option flag" ;
		$nvdt[3] = "integer" ;
		AddItem (@nvdt) ;
		
		$nvdt[0] = "drampbc" ;
		$nvdt[1] = $tmpLine[1] ;
		$nvdt[2] = "ramp up period" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;
	}

#Get tempmin, tempmax, saltmin, saltmax
	@names = ("tempmin", "tempmax", "saltmin", "saltmax"); 
	$str = <pHandle>;
	chomp ($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "tempmin" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Minimum Value for Temperature" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;
	
	$nvdt[0] = "tempmax" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = "Maximum value for temperature" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "saltmin" ;
	$nvdt[1] = $tmpLine[2] ;
	$nvdt[2] = "Minimum Value for Salinity;float;" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "saltmax" ;
	$nvdt[1] = $tmpLine[3] ;
	$nvdt[2] = "Maximum value for salinity" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;
	

#Get rnday
	$str = <pHandle>;
	chomp ($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Total number of run days" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

#Get nramp, dramp
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "nramp" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "ramp option for the tides" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "dramp" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = "ramp-up period in days" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

#Get dt
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "external time step(in secs) for momentum and continuity equations" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

#Get nsubfl
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nsubfl = $nvdt[1] ;
	$nvdt[2] = "flag to determine how the number of divisons in backtracking are to be computed" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

#Get NDELT (logic is built in)
	$str = <pHandle> ;
	chomp($str) ;
	if ($nsubfl == 2) 				# if nsubfl = 2
	{
		@tmpLine  = split(/\s/, $str);
		$nvdt[0] = "ndeltmin" ;
		$nvdt[1] = $tmpLine[0] ;
		$nvdt[2] = "Minimum number of subdivisons allowed" ;
		$nvdt[3] = "integer" ;
		AddItem (@nvdt) ;

		$nvdt[0] = "ndeltmax" ;
		$nvdt[1] = $tmpLine[1] ;
		$nvdt[2] = "Maximum number of subdividons allowed" ;
		$nvdt[3] = "integer" ;
		AddItem (@nvdt) ;
	}
	if ($nsubfl == 0)
	{ 
		@tmpLine = split (/\s/,$str) ;
		$nvdt[0] = "ndelt" ;
		$nvdt[1] = $tmpLine[0] ;
		$nvdt[2] =  "Constant number of subdivisons" ;
		$nvdt[3] = "integer" ;
		AddItem (@ndvt) ;
	}

#Get nadv
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;	
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Advection on off switch" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

#Get h0
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = 'h0' ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "minimum depth in meters" ;	
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

#Get ntau
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] ="ntau" ;
	$nvdt[1] = $tmpLine[0] ;
	$ntau = $nvdt[1] ;
	$nvdt[2] = "Constant drag coefficient" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

#Get constant drag coefficient CD0 if it exists 
	if ($ntau == 0)
	{
		$str = <pHandle> ;
		chomp ($str) ;
		@tmpLine = split (/\s/,$str) ;
		$nvdt[0] = "Cd0" ;
		$nvdt[1] = $tmpLine[0] ;
		$nvdt[2] = "Constant drag coefficient" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;
	}
 
#Get ncor
	$str = <pHandle> ;
	chomp ($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "ncor" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Constant coriolis parameter"  ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

#Get nws, wtiminc
		$str = <pHandle>;
		chomp ($str) ;
		@tmpLine = split (/\s/,$str) ;
		@names = ("nws", "wtiminc"); 
		$nvdt[0] = "nws" ;
		$nvdt[1] = $tmpLine[0] ;
		$nws = $tmpLine[0] ;
		$nvdt[2] = "Wind forcing option" ;
		$nvdt[3] = "integer" ;
		AddItem (@nvdt) ;
		
		$nvdt[0] = "wtiminc" ;
		$nvdt[1] = $tmpLine[1] ;
		$nvdt[2] = "Interval with which input for wind is read in" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;

#Get nrampwind, drampwind if they exist
	if ($nws > 0)
	{
		$str = <pHandle> ;
		chomp($str) ;
		@names = ("nrampwind", "drampwind"); 
		@tmpLine = split (/\s/,$str) ;
		
		$nvdt[0] = "nrampwind" ;
		$nvdt[1] = $tmpLine[0] ;
		$nvdt[2] = "Ramp up option for wind" ;
		$nvdt[3] = "integer" ;
		AddItem (@nvdt) ;
		
		$nvdt[0] = "drampwind" ;
		$nvdt[1] = $tmpLine[1] ;
		$nvdt[2] = "Ramp period for wind" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;
	}

#Get ihconsv, isconsv 
	$str = <pHandle> ;
	@names = ("ihconsv", "isconsv"); 
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "ihconsv" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Heat budget flag" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;
	
	$nvdt[0] = "isconsv" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = "Salt conversstion model flags" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

#Get itur
	$str = <pHandle>;
	chomp($str) ;

	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "itur" ;
	$nvdt[1] = $tmpLine[0] ;
	$itur = $nvdt[1] ;
	$nvdt[2] = "Turbulence closure flag" ;
	$nvdt[3] = "integer" ;
	AddItem(@nvdt) ;

#Get the next line which is based on itur
	$str = <pHandle>;
	chomp ($str) ;
	@tmpLine = split (/\s/,$str) ;
	if ($itur == 0) {
		$nvdt[0] = "vdiff" ;
		$nvdt[1] = $tmpLine[0] ;
		$nvdt[2] = "constant diffusives for momentum" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;

		$nvdt[0] = "tdiff" ;
		$nvdt[1] = $tmpLine[1] ;
		$nvdt[2] =  "constant diffsuives for transport" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;

	} elsif ($itur == 2) {
		$nvdt[0] = "tdiff_min" ;
		$nvdt[1] = $tmpLine[0] ;
		$nvdt[2] = "Unkown" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;

		$nvdt[0] = "hestu_pp" ;
		$nvdt[1] = $tmpLine[1] ;
		$nvdt[2] = "unkown" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;
		
		$nvdt[0] = "vdmax1" ;
		$nvdt[1] = $tmpLine[2] ;
		$nvdt[2] = "unkown" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;
		
		$nvdt[0] = "vdmin1" ;
		$nvdt[1] = $tmpLine[3] ;
		$nvdt[2] = "unknown" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;

		$nvdt[0] = "hcont_pp" ;
		$nvdt[1] = $tmpLine[3] ;
		$nvdt[2] = "unknown" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;
		
		$nvdt[0] = "vdmax2" ;
		$nvdt[1] = $tmpLine[3] ;
		$nvdt[2] = "unknown" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;

		$nvdt[0] = "vdmin2" ;
		$nvdt[1] = $tmpLine[3] ;
		$nvdt[2] = "unknown" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt) ;

	} elsif ($itur == 3) {
		@names = ("bgdiff", "diff_max", "hest_my", "hcont_my",
		"xlmin_est", "xlmin_sea"); 
		$nvdt[0] = "bgdiff" ;
		$nvdt[1] = $tmpLine[0] ;
		$nvdt[2] = "" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt); 

		$nvdt[0] = "hestu_my" ;
		$nvdt[1] = $tmpLine[1] ;
		$nvdt[2] = "" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt); 
	
		$nvdt[0] = "diffmax_est" ;
		$nvdt[1] = $tmpLine[2] ;
		$nvdt[2] = "" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt); 


		$nvdt[0] = "xlmin_est" ;
		$nvdt[1] = $tmpLine[3] ;
		$nvdt[2] = "" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt); 

	
		$nvdt[0] = "hcont_my" ;
		$nvdt[1] = $tmpLine[4] ;
		$nvdt[2] = "" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt); 

		$nvdt[0] = "diffmax_sea" ;
		$nvdt[1] = $tmpLine[5] ;
		$nvdt[2] = "" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt); 

		$nvdt[0] = "xlmin_sea" ;
		$nvdt[1] = $tmpLine[5] ;
		$nvdt[2] = "" ;
		$nvdt[3] = "float" ;
		AddItem (@nvdt); 
	}

#Get ihcorcon, horcon 
	$str = <pHandle> ;	
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "ihorcon" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Horizontal diffusion option" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;
		
	$nvdt[0] = "horcon" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = "Constant diffusion constant" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

#Skip next two inactive lines
	$str = <pHandle>;
	$str = <pHandle>;

#Get ictemp, icsalt 
	$str = <pHandle>;
	chomp($str) ;	
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "ictemp" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvtd[2] = "Option for specifying initial temperatur" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "icsalt" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] =  "Option for specifying initial salinity" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;
		
#Get isponge
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "isponge" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Unknown" ;
	$nvdt[3] = "integer" ;
	#AddItem (@nvdt) ;

# Get ntip
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	
	$nvdt[0] = "ntip" ;
	$nvdt[1] = $tmpLine[0] ;
	$ntip  = $nvdt[1] ;
	$nvdt[2] = "Total Number of tidal forcing frequencies" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;
	
	$nvdt[0] = "tip_dp" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = "Cut off depth for appkying tidal potential" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

# Get talpha, jspc, tamp, tfreq , tnf, tear
	$text ="" ;
	for ($i=0; $i<$ntip ; $i++)
	{
		$str =  <pHandle> ;
		$text = $text . $str ;
		$str = <pHandle> ;
		$text = $text . $str ;
	}
	$nvdt[0] = "ntip_data" ;
	$nvdt[1] = $text ;
	$nvdt[2] = "unknown" ;
	$nvdt[3] = "array" ;
	AddItem (@nvdt) ;

#Get nbfr
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "nbfr" ;
	$nvdt[1] = $tmpLine[0] ;
	$nbfr = $tmpLine[0] ;
	$nvdt[2] = "Total number of tidal bounding frequencies" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

#Get alpha(k) - amig(k), ff(k), face(k), for i = 1 to nbfr

	$text = "" ;
	for(my $i=0; $i < $nbfr; $i++){	
		$str = <pHandle>;   						# read the tidal constituent
		$text = $text . $str ;
		$str = <pHandle>;	
		$text = $text . $str ;
		chomp($str) ;
	}
	$nvdt[0] = "nbfr_data" ;
	$nvdt[1] = $text ;
	$nvdt[2] = "unknown" ;
	$nvdt[3] = "array" ;
	AddItem (@nvdt) ;
	

#Get nope
	$str = <pHandle>;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = $tmpLine[$#tmpLine] ;
	$nvdt[1] = $tmpLine[0] ;
	$nope = $nvdt[1] ;
	$nvdt[2] = "Number of open boundaries" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

#Get netaelem, iettype, ifltype, itetype, isatype 
	$text = "" ;
	for ($i=0; $i<$nope; $i++)
	{
		$str = <pHandle>;
		$text = $text . $str ;
		@tmpLastLine = split (/\s/,$str) ;
		$ntmp = $tmpLastLine[0] ;
		$iettype = $tmpLastLine[1] ;
		$ifltype = $tmpLastLine[2] ;
		$itetype = $tmpLastLine[3] ;
		$isatype = $tmpLastLine[4] ;
		if ($iettype == 2)
		{
			$str = <pHandle> ;
			$text = $text . $str ;
		}
		if ($iettype == 3)
		{
			for ($k=0 ; $k < $nbfr ; $k++)
			{
				$str = <pHandle> ;
				$text = $text . $str ;
				for ($n=1 ; $n<=$ntmp ; $n++ )
				{
					$str = <pHandle> ;
					$text = $text . $str ;
				}
			}
		}
		if  ($ifltype == 2)
		{
			$str = <pHandle> ;
			$text = $text . $str ;
		}
		if ($itetype == 2 || $itetype == -1)
		{
			$str = <pHandle> ;
			$text = $text . $str ;
		}
		if ($isatype == -1 || $isatype==2)
		{
			$str = <pHandle> ;
			$text = $text . $str ;
		}
	}
	$nvdt[0] = "nope_data" ;
	$nvdt[1] = $text ;
	$nvdt[2] = "unknow" ;
	$nvdt[3] = "array" ;
	AddItem (@nvdt) ;

# get Nspool,ihfskip
	$str = <pHandle> ;
	chomp ($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "nspool" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Global output skip" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "ihfskip" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = "global output skip" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get noutge
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "noutge" ;
	$nvdt[1] =$tmpLine[0] ;
	$nvdt[2] = "global output elevation control" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;


# Get atmospheric pressure
	$str = <pHandle> ;
	chomp ($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_atmosPress" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Output option for Atmospheric Pressure" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get air Temperature
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_airTemp" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Output option for Air Temperature" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;
	

# Get Specific humidity
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "out_humidity" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Output option for specific humidity" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;


# Get Solar Radition
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_solar" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Output option for solar radition" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get Short Wave  Radition
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_short_wave" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Output option for short wave radiation" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;


# Get  Long Wave  Radition
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_long_wave" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Ouput option for long wave radiation" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get  Upward heat flux
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_upward_heat_flux" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "output option for upward heat flux" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get  Downward flux
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_downward_flux" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "output option for downward flux" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;


# Get  Total flux
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_total_flux" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "output option for total flux" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get  wind speed 
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_wind_speed" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "output option for wind speed" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get  wind stress
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_wind_stress" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "output option for wind stress" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;


# Get horizontal velocity
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_hor_velocity" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Output option for horizontal velocity" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get vertical velocity 
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_ver_velocity" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Output option for vertical velocity" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get temperature 
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "temp" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] ="Output option for temperature" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;


# Get salinity  
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "salinity" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Output option for salinity" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;


# Get densitivity 
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "densitivity" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Output option for densitivity" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get diffusitivity 
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "Diffusitivity" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "output option for diffusitivity" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get turbulent kinetic enegery 
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_kinetic" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "output option for turbulent kinetic energy" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get macroscale mixing length 
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_macro" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "output option for macrscale mixing length" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get test output param
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "out_test" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "output option for test variable" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# get nhstr
	$str = <pHandle> ;
	chomp ($str) ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "nhstar";
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Hot start output control paraemeter" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;
	
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "isolver" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "ITPACK solver control parameter" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "itmax1" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = "unknown" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "iremove" ;
	$nvdt[1] = $tmpLine[2] ;
	$nvdt[2] = "unknown" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "zeta" ;
	$nvdt[1] = $tmpLine[3] ;
	$nvdt[2] = "unknown" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "tol" ;
	$nvdt[1] = $tmpLine[4] ;
	$nvdt[2] = "unknown" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# Get iflux , ihccheck
	$str = <pHandle> ;
	chomp($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "iflux" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Parameter for checking heat, volume and salt budget balances" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "ihccheck" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = "Some Flag" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

# get iwmode
	$str = <pHandle> ;
	@tmpLine = split(/\s/,$str) ;
	$nvdt[0] = "iwmode" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "flag to decide whether continuity eq or vertical momentum eq is used to solve for w" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

#get nsplit , dvel00 , mnsom00
	$str = <pHandle> ;
	chomp ($str) ;
	@tmpLine = split (/\s/,$str) ;
	$nvdt[0] = "nsplit" ;
	$nvdt[1] = $tmpLine[0] ;
	$nvdt[2] = "Mode splittying factor" ;
	$nvdt[3] = "integer" ;
	AddItem (@nvdt) ;

	$nvdt[0] = "dvel00" ;
	$nvdt[1] = $tmpLine[1] ;
	$nvdt[2] = "Minmum velocity gradient for smoothing" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;
	
	$nvdt[0] = "mnsom00" ;
	$nvdt[1] = $tmpLine[2] ;
	$nvdt[2] = "Max # of iterations in smoothing" ;
	$nvdt[3] = "float" ;
	AddItem (@nvdt) ;

close(pHandle);

 return(@rows);
}
sub ChompNLs {
	chomp $rows[$indx];
}

sub GetMulValLine {
	my (@valNames) = @_;    # Names of the parameters whose values are to be extracted 
	my @vals;		# The param values for this line
	my @tmpLine;		# Temp array storage for line values

	@vals = split(/\s/, $str);   # v1 v2 .. vn   n1 n2 .. nn

	for(my $count=0; $count <= $#valNames; $count++){	# For each parameter
		$tmpLine[0] = $valNames[$count];		# Name of the parameter
		$tmpLine[1] = $vals[$count];			# value of parameter
		$rows[$indx] = join(';', $tmpLine[0],$tmpLine[1]); # Separate them with ;
		$rows[$indx] = $rows[$indx] . ";";		# Trailing ;
		ChompNLs();					# Remove newlines
		$indx++ ;
	}
}

sub GetSingleValLine {
	my @tmpLine;						# Temp array storage for line values
	my $counter = 1; 					# Used to loop through the tmp array
	chomp $str;						# Remove new line character from str
	@tmpLine  = split(/\s/, $str);				# Separate the name and value in the line \s refers to whitespace characters
							
		while (!($tmpLine[$counter])){		
			 $tmpLine[$counter];
			$counter++;
		}
		$rows[$indx] = join(';',$tmpLine[$counter], $tmpLine[0]); # join name and value
		$rows[$indx] = $rows[$indx] . ";";			  # Put a trailing ;
	ChompNLs();
}
#sub AddItem
#{
#	@nvdt = @_ ;   			# Arguments passed to AddItem, Name, Value, Description and Type
#	$name = $nvdt[0] ;
#	$value = $nvdt[1] ;
#	$description = $nvdt[2] ;
#	$type = $nvdt[3] ;
#	if ($type eq "array")
#	{
#		@list=split (/\n/,$text) ;
#		$nlines = $#list+1 ;
#		print "$name;$nlines;$description;$type;\n" ;
#		print $value ;
#	}
#	else
#	{
#		print "$name;$value;$description;$type;\n" ;
#	}
#}
