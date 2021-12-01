use strict;
use warnings;
use diagnostics;
use feature 'say';
use feature "switch";
# Module for minimum number among a list
use List::Util qw(min);

# EDIT DISTANCE FUNCTION
# ----------------------
# accepts two strings str1 and str2.
# returns edit distance between them.
sub distance {
    my ($str1, $str2) = @_;
    my @arr1= split( //, $str1);
    my @arr2= split( //, $str2);
    my @dist;
    $dist[$_][0]= $_ foreach (0 .. @arr1);
    $dist[0][$_]= $_ foreach (0 .. @arr2);
    foreach my $i (1 .. @arr1){
        foreach my $j (1 .. @arr2){
            my $cost= $arr1[$i - 1] eq $arr2[$j - 1] ? 0 : 1;
    	    $dist[$i][$j]= min(
                            $dist[$i - 1][$j] + 1,
                            $dist[$i][$j - 1] + 1,
                            $dist[$i - 1][$j - 1] + $cost 
                            );
        }
    }
    return $dist[@arr1][@arr2];
}

################################################

# The program needs an input file provided in command line arguments, 
#    so first we check that.
my $num_command_line_arg = $#ARGV;

# error handling
if($num_command_line_arg < 1) {
    say "Please specify the name of the file to check.";
    exit;
} elsif($num_command_line_arg > 1) {
    say "This script handle one file at a time!";
    exit;
}

############################################

# The script treats two types of words- normal english words and linux commands.

# English words
#---------------
# The dictionary used in this program has words arranged in order of their frequency of use.
# So we take in the words in hash as well as in an array, we'll use hash when finding a perfect match
#  and when finding the closest word for replacement, we'll use array 
# This way the most used word would be suggested, otherwise it would be the first word in lexicographical order.

# open dictionary file
open(my $in,  "<",  "words.txt")  or die "Can't open words.txt: $!"; 

# initialize hash table and array
my %dict_hash;
my @dict_array;
while (<$in>) {     
	chomp; # cuts till next newline

    # adding the word to hash table and array
	$dict_hash{"$_"}= $_;
    push @dict_array, $_;
}
#  closing words.txt
close $in or die "Can not close words.txt : $!";

# Linux commands
# --------------

# open the file
open(my $lin, "<", "linux_coms.txt") or die "Can not open linux_coms.txt : $!";

#initialize hash table
my %dict_lin;
while (<$lin>){
    chomp; # cut till next line
    $dict_lin{"$_"}=$_; # added words to dictionary
}
# closing linux_coms.txt 
close $lin or die "Can not close linux_coms.txt : $!";


############################################

# Input file
# ------------
# The input file name-path will be provided as a command line argument, accessible through ARGV array.
# opening input file
open(my $ff, "<", $ARGV[0]) or die "Can not open input file : $!"; 

my @inputs; # initialize inputs array, each value of this array is a line of input file.

while(<$ff>){
    chomp; # cut till new line
    push @inputs, $_; # add to array
}
close $ff or die "Can not close input file : $!"; # input file closed

#############################################

# specifing actions to user
printf("For every suggestion, press y to accept and n to skip:\n\n"); 

# opening the output file to write on:
open(my $out, ">", $ARGV[1]) or die "Can't open output file : $!";

my $num_corrections = 0; # count of number of corrections done yet

# The script goes through each line of input file and checks each word.
foreach my $line (@inputs){
    
    my @words = split(/ /, $line); # we take the words from that line and store in this words array

    my $pos = 0; # this variable will specify where to print ^ on line
    
    foreach my $given_word (@words){

        # skipping if its an empty string
        if($given_word eq ""){
            $pos++;
            next;
        }

        my $len =length($given_word); # storing lenght 
        my $done =0; # turn this one when finished.

        # if its a linux command, it can be directly searched in dict_lin but
        # if its a english word we'll check if (a) if has ' e.g. I'll and (b) if it has . ? etc at the end.

        # checking if its a linux commmand
        # ---------------------------------
        my $lin_com_sugg="";

        if(exists $dict_lin{$given_word}){
            #say "linux command found!", $given_word;
            $pos+=$len+1;
            next;
        } # checking if a close string exists
        else{
            foreach my $com (%dict_lin){ # checking all words in dictionary
                if(abs($len -length($com))<=1){ # lenght difference of atmost 1
                    my $len_diff= abs($len - length($com));
                    if (distance($given_word, $com)<=2-$len_diff) { # distance of 2 for same lenght, 1 for different lenght words
                        $lin_com_sugg=$com; # saving the suggestion
                        last;
                    }
                }
            }
        }

        #checking if its a english word
        # ------------------------------

        # This script won't handle words like I'll or can't, etc.
        if( $given_word =~ /[\']/){ 
            #say "Skipped for ", $given_word;
            if(  $lin_com_sugg ne ""){
                # if the command has a close suggestion in linux dictionary
                # then we recommend it to user:

                # first printing the complete line:
                say $line;
                for(my $i=0;$i<$pos;$i++){ printf(" ");} # printing appropriate amount of spaces
                printf("^ %s", $lin_com_sugg);  # printing ^ followed by suggestion

                printf("\n(y/n):"); # asking user for yes/no
                my $confirmation =<STDIN>; # getting user's input
                chomp($confirmation); # remove newline at the end

                if($confirmation eq "y" || $confirmation eq "Y"){ # if user confirmed
                    substr($line, $pos, $len) = $lin_com_sugg; # changed the word
                    $num_corrections++;
                }
                printf("\n");
            }
            $pos+=$len+1; # updating the position of cursor
            next;

        }
        # removing . , ; ! ? at the end of words.
        my $end_char=substr($given_word, $len-1, 1); # substr starting at last char and of lenght 1 = last char.
        my $the_word_is_cropped=0; # flag to indicate whether word is cropped or not.
        if($end_char =~ /[.,;!?]/){                      # if the end character is one of these,
            $given_word =substr($given_word, 0, $len-1); # then we cut it out.
            $the_word_is_cropped=1;
        }

        # lowercasing the word, since the dictionary contains all lowercase words 
        $given_word = lc $given_word;

        my $eng_suggestion;

        if(!(exists $dict_hash{$given_word})){ # if the word is not in the dictionary,
            foreach(@dict_array){              # then we search thru the dict array for finding a close match.
                my $len_diff = abs($len - length($_));
                if( $len_diff <= 1){        # only if difference in lenght is of atmost 1 unit (this speeds up the process)
                    if(distance($given_word, $_) + $len_diff<=2) { # same length, allowed distance 2, but for different lenght allowed distance 1.
                        $eng_suggestion=$_; # storing the suggestion
                        $done =1; # flag
                        last;
                    }
                }
            }
            if($done==1){
                # recommending suggestion:
                say $line; # first print the line
                for(my $i=0;$i<$pos;$i++){ printf(" ");} # printing appropriate amount of spaces
                printf("^ %s", $eng_suggestion); # then ^ to mark the word, followed by our suggestion

                printf("\n(y/n):"); # asking user
                my $confirmation =<STDIN>;

                chomp($confirmation); # remove newline
                if($confirmation eq "y" || $confirmation eq "Y"){ # if user responds with y
                    $num_corrections++;
                    substr($line, $pos, $len-$the_word_is_cropped) = $eng_suggestion; #changed word
                }
                printf("\n");
            }
            else{
                if( $lin_com_sugg ne "" ){
                    # recommending suggestion:
                    say $line; # first print the line
                    for(my $i=0;$i<$pos;$i++){ printf(" ");} # printing appropriate amount of spaces
                    printf("^ %s", $lin_com_sugg); # then ^ to mark the word, followed by suggestion

                    printf("\n(y/n):"); # asking user
                    my $confirmation =<STDIN>;

                    chomp($confirmation); # remove new line
                    if($confirmation eq "y" || $confirmation eq "Y"){ # if user responds with y
                        substr($line, $pos, $len) = $lin_com_sugg; # changed word
                        $num_corrections++;
                    }
                    printf("\n");
                } 
            }
        }
        else{
        }
        $pos+=$len+1; # before moving to next word, we update the postion mark
    }

    # Now we have a line that we'll write to output file.
    print $out "$line\n";

}

# done with script, closing output file
close $out or die "Can't close output file: $!";

# printing info
printf("\nReached end of file, %d corrections made.\n", $num_corrections);