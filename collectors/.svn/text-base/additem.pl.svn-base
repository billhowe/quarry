# AddItem : Add one item to the DB and XML file
# Inputs
#         Name
#         Value
#         Description
#	  Type
# Type can be integer / float / string / array 

sub AddItem
{
        #push(@descriptors,[@_]);
	@nvdt = @_ ;   			# Arguments passed to AddItem, Name, Value, Description and Type
	$name = $nvdt[0] ;
	$value = $nvdt[1] ;
	$description = $nvdt[2] ;
	$type = $nvdt[3] ;
        open(FILE, ">>/tmp/perloutput.tmp");
	#print "$name;$nlines;$description;$type;\n" ;
	#if ($type eq "array")
	#{
	#	@list=split (/\n/,$text) ;
	#	$nlines = $#list+1 ;
	#        print FILE "$name;$nlines;$description;$type;\n" ;
	#        print FILE $value ;
#
#	}
#	else
#	{
	      print FILE "$name;$value;$description;$type;\n" ;
        close FILE;
	
#	        print "$name;$value;$description;$type;\n" ;

#	}
}
1;
