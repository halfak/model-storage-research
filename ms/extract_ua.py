import sys, user_agents

from menagerie.formatting import tsv

def main():
	reader = tsv.Reader(sys.stdin, types=[int, str])
	writer = tsv.Writer(sys.stdout)
	
	for i, row in enumerate(reader):
		ua = user_agents.parse(row.event_userAgent)
		if i % 10000 == 0: sys.stderr.write("%6d: " % i)
		if (i+1) % 10000 == 0: sys.stderr.write("\n")
		if i % 100 == 0: sys.stderr.write(".")
		
		writer.write([
			row.id,
			ua.browser.family,
			ua.os.family,
			ua.device.family
		])
	
	sys.stderr.write("\n")
