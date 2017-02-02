import sys, argparse

from menagerie.formatting import tsv
from menagerie.iteration import aggregate

def main():
	
	reader = tsv.Reader(sys.stdin, headers=tsv.Reader.FIRST_LINE)
	writer = tsv.Writer(sys.stdout)
	
	for i, (id, user_rows) in enumerate(aggregate(reader, by=lambda row: row['event_experimentId'])):
		if i % 100 == 0: sys.stderr.write(".")
		for user_i, row in enumerate(user_rows):
			
			writer.write(row.values() + [user_i])
		
	
	sys.stderr.write("\n")

if __name__ == "__main__": main()