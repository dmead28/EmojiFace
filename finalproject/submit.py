import time
import os
import sys
import argparse
import json
from bonnie.submission import Submission

def main():
  parser = argparse.ArgumentParser(description='Submits code to the Udacity site.')
  parser.add_argument('--provider', choices = ['gt', 'udacity'], default = 'gt')
  parser.add_argument('--environment', choices = ['local', 'development', 'staging', 'production'], default = 'production')
  parser.add_argument('--writeup', action='store_true', default=False)

  args = parser.parse_args()

  quiz = 'finalproject'
  filenames = ["finalproject.pdf"]

  if not os.path.isfile(filenames[0]):
    print "%s is not present in the directory." %  filenames[0]
    return
  elif (os.stat(filenames[0]).st_size >> 20) >= 6:
    print "Please keep your files under 6MB."
    return

  submission = Submission('cs6475', quiz, 
                          filenames = filenames, 
                          environment = args.environment, 
                          provider = args.provider)

  while not submission.poll():
    time.sleep(3.0)

  if submission.result():
    result = submission.result()
    print json.dumps(result, indent=4)
  elif submission.error_report():
    error_report = submission.error_report()
    print json.dumps(error_report, indent=4)
  else:
    print "Unknown error."

if __name__ == '__main__':
  main()
