# Copyright (C) 2012 Brian Wesley Baugh
#
# This work is licensed under the Creative Commons
# Attribution-NonCommercial-ShareAlike 3.0 Unported License.
# To view a copy of this license, visit:
# http://creativecommons.org/licenses/by-nc-sa/3.0/
#
# This file was created using the streaming example from Tweepy
# as a general guide. Tweepy is licensed under the MIT License
# and is Copyright (c) 2009-2010 Joshua Roesslein.
"""Collects all tweets from the sample Public stream using Twitter's
streaming API, and saves them to a file for later use as a corpus.

The sample Public stream "Returns a small random sample of all public
statuses. The Tweets returned by the default access level are the same,
so if two different clients connect to this endpoint, they will see the
same Tweets."

This module consumes tweets from the sample Public stream and putes them
on a queue. The tweets are then consumed from the queue by writing them
to a file in JSON format as sent by twitter, with one tweet per line.
This file can then be processed and filtered as necessary to create a
corpus of tweets for use with Machine Learning, Natural Language Processing,
and other Human-Centered Computing applications.
"""

import sys
import threading
import Queue
import codecs
import time
import socket
import httplib
import string

from tweepy.streaming import StreamListener
from tweepy import OAuthHandler
from tweepy import Stream
from tweepy.utils import import_simplejson
json = import_simplejson()


# TODO(bwbaugh): Make the following global vars loadable from a config file.

# Go to http://dev.twitter.com and create an app.
# The consumer key and secret will be generated for you after
consumer_key = "zhvCUIKGvcQPsgDuwlaDg"
consumer_secret = "wv7K29Ki0QWUJX2qHVoELEPd9I4ycTLVWOukaCkB1AE"

# After the step above, you will be redirected to your app's page.
# Create an access token under the the "Your access token" section
access_token = "762503640-RGfSrzmatI7tLQGZykuYubCwYUBaPkOQOMh6Dimn"
access_token_secret = "jtx62PsQ0OBNITi2QwMuKt80MHwg5IoGWIRNA6Ml4"

# Filename of the corpus that will be used to store the tweets.
# TODO(bwbaugh): Add feature to make the file rotatable by time or size.
basedir = '/u/metanet/corpolexica/twitter/'
corpus_fname = basedir + "tweet-stream.json2"
#corpus_fname_es = basedir + "tweet-stream.json.en"
#corpus_fname_ru = basedir + "tweet-stream.json.ru"
#corpus_fname_ar = basedir + "tweet-stream.json.ar"

# Number of seconds to wait after an exception before restarting the stream.
tcpip_delay = 0.25
MAX_TCPIP_TIMEOUT = 16
http_delay = 5
MAX_HTTP_TIMEOUT = 320


class QueueListener(StreamListener):
    """Tweets received from the stream are stored in an internal queue.

    Get tweets from the internal queue directly in order to process them.
    For example, in this module the tweets are taken off the queue to be
    written to a file, however they could just as easily be processed on
    the fly.
    """
    def __init__(self):
        """Creates a new stream listener with an internal queue for tweets."""
        super(QueueListener, self).__init__()
        self.num_handled = 0
        self.queue = Queue.Queue()

    def on_data(self, data):
        """Routes the raw stream data to the appropriate method."""
        data_json = json.loads(data)
        data_json['id'] = ''
        data_json['created_at'] = ''
        data_json['id_str'] = ''
        data_json['source'] = ''
        data_json['screen_name'] = ''
        data_json['contributors'] = ''
        data_json['profile_image_url'] = ''
        data_json['filter_level'] = ''
        if 'in_reply_to_status_id' in data_json:
            if self.on_status(data) is False:
                return False
        elif 'limit' in data_json:
            if self.on_limit(data_json['limit']['track']) is False:
                return False
        return True

    def on_status(self, data):
        """Puts each tweet in JSON format in the queue and increments count."""
        # Note that in this overridden method 'data' is a string whereas
        # in the default listener method this method is passed an object in the
        # format of: status = Status.parse(self.api, json.loads(data))
        self.queue.put(data)
        self.num_handled += 1

    def on_error(self, status):
        """Prints any error to the console but does not halt the stream."""
        print
        print '*** ON ERROR ***'
        print status

    def on_limit(self, track):
        """Prints any limit notice to the console but doesn't halt.

        Limit notices indicate that additional tweets matched a filter,
        however they were above an artificial limit placed on the stream
        and were not sent. The value of 'track' indicates how many tweets
        in total matched the filter but were not sent since the stream
        was opened.
        """
        print
        print '*** ON LIMIT ***'
        print track


def print_status(listener, seconds=5.0, last_count=0):
    """Call once to repeatedly display statistics every N seconds."""
    num_handled = listener.num_handled
    qsize = listener.queue.qsize()

    t = threading.Timer(seconds, print_status, args=[listener, seconds,
                                                     num_handled])
    t.daemon = True
    t.start()

    print
    print 'TOTAL TWEETS HANDLED: %d' % num_handled
    print ('NUM IN THE PAST %d seconds: %d (%d per sec)' %
           (seconds, num_handled - last_count,
            (num_handled - last_count) / seconds))
    if qsize > 0:
        print 'QUEUE SIZE: %d' % qsize


def worker(listener, flush_every=1):
    """Takes tweets off of the queue and writes them to a file."""
    with codecs.open(corpus_fname, mode='a', encoding='utf-8') as f:
        count = 0
        count2 = 0
        sample_every = 2
        while True:
            data = listener.queue.get()            
            if data is None:
                listener.queue.task_done()
                break
            if count2==0:
                textt = data[string.find(data, '"text":'):]
                textt = textt[:string.find(textt, ',')]

                lang = data[string.find(data, '"lang":'):]
                lang = lang[:string.find(lang, ',')]

                location = data[string.find(data, '"location":'):]
                location = location[:string.find(location, ',')]

                followers_count = data[string.find(data, '"followers_count":'):]
                followers_count = followers_count[:string.find(followers_count, ',')]
            
                favourites_count = data[string.find(data, '"favourites_count":'):]
                favourites_count = favourites_count[:string.find(favourites_count, ',')]
            
                geo = data[string.find(data, '"geo":'):]
                geo = geo[:string.find(geo, ',')]

                coordinates = data[string.find(data, '"coordinates":'):]
                coordinates = coordinates[:string.find(coordinates, ',')]
                
                sep = ', '
                data = textt + sep + lang + sep + location + sep + followers_count + sep + favourites_count + sep + geo + sep + coordinates
                f.write(data + '\n')
                count += 1
                count2 +=1
            else:
                count2 +=1
            if count2 ==sample_every:
                count2 = 0
            if count == flush_every:
                f.flush()
                count = 0
            listener.queue.task_done()


def main():
    """Connects to the stream and starts threads to write them to a file."""
    listener = QueueListener()
    auth = OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)

    writer_thread = threading.Thread(target=worker, args=(listener,))
    writer_thread.start()

    stream = Stream(auth, listener)

    print_status(listener)

    while True:
        try:
            stream.sample()  # blocking!
        except KeyboardInterrupt:
            print 'KEYBOARD INTERRUPT:'
            return
        except (socket.error, httplib.HTTPException):
            global tcpip_delay
            print ('TCP/IP Error: Restarting after '
                   '{} seconds.'.format(tcpip_delay))
            time.sleep(min(tcpip_delay, MAX_TCPIP_TIMEOUT))
            tcpip_delay += 0.25
        finally:
            print 'Disconnecting stream'
            stream.disconnect()
            print 'Waiting for last tweets to finish processing'
            # Send poison pill to writer thread and wait for it to exit
            listener.queue.put(None)
            listener.queue.join()
            print 'Waiting for writer thread to finish'
            writer_thread.join()
            print 'Exit successful'

if __name__ == '__main__':
    sys.exit(main())
