# Perl Script spell checker

The spell checker works as follows: 
	
you have a text file ( for testing purposes, file input.txt is given in submission folder) and this files has some typos. So, run the following command:
```
		perl pe.pl input.txt output.txt
```
the script will read lines from input.txt and write to output.txt .
	
It checks each word for whether it exists in dictionaries( more info on dictionaries below) and if a possible recommendation is found, it prints that one line (containing misspelled word) over on terminal, and then prompts user to either accept or reject.
	
If the users types y and presses enter, it will replace that one word into the suggestion,and print the resulting line to output.txt file. If user rejects by pressing n, the word remains as it is.
	
After running through whole file the scripts ends and saves all changes to output.txt file.
	
Note: The input has to be specified from the file whose name as been given as a command line argument.
	
## Information regarding dictionaries:

This script uses 2 files, words.txt which contains english words sorted by their frequency of use,and linux_coms.txt which contains a list of linux commands.
	
The words in words.txt are sorted by their frequency of use in english language, which ensures more accurate suggestions for misspelled words. For example, waht is closer to want than what,but given that what is used in english much more frequently, the script suggests what for recommendation.
		
It uses edit distance of 2 for words that have same lenght, but edit distance of 1 for words that differ in lenght by 1 unit. The reasoning behind this is as follows: people generally make 2 types of typos: pressing one before another (thus words like waht for what) or missing to press a key("wll" in place of "will"). 

Given that the script searches in both these files, the suggestions for linux commands might not be accurate for those with a few letters. For example, "lss" would be matched with both "less" and "ls". The script only recommends one word for each misspelling it encounters.
	
Note: don't change names of dictionary files, the script won't be able to access them otherwise.
