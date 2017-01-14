---
title: Leverage the "J" in JRuby for Powerful Concurrency
---

<p>I was working on a project that required some heavy-weight processing of links to determine if they were valid based on a variety of criteria. Since the standard Ruby interpreter was running each process sequentially the naive approach was taking a prohibitively long time. Fortunately this was a simple pure Ruby problem and each record was processed independantly of each other this was a good opportunity to use JRuby and it's Java interoperability to get some real concurrency power.</p>

<p>Since the app was only running off the command line it was easiest to run it as a script. I'm not including the <code>lib</code> since it's not relevant for this example.</p>

{% highlight ruby %}
#!/usr/bin/env jruby

require_relative '../lib/schrute'

{% endhighlight %}

<p>Using the ruby-concurrent library and JRuby interop I loaded in the Java Futures libraries.</p>

{% highlight ruby %}

require 'csv'
require 'thread_safe'

java_import java.util.concurrent.Callable
java_import java.util.concurrent.Executors
java_import java.util.concurrent.FutureTask
java_import java.util.concurrent.LinkedBlockingQueue
java_import java.util.concurrent.ThreadPoolExecutor
java_import java.util.concurrent.TimeUnit

{% endhighlight %}

<p>Since the goal is to squeeze as many executions as possible I set the pool size to saturate all available cores.</p>

{% highlight ruby %}

POOL_SIZE = java.lang.Runtime.getRuntime.availableProcessors * java.lang.Runtime.getRuntime.availableProcessors

{% endhighlight %}

<p>The application reads in a CSV and writes each row into a threadsafe array for later processing. Since the input itself wasn't the bottleneck sequentially reading in the file had little impact on the execution time.</p>

{% highlight ruby %}

class App
  def initialize(file_to_process)
    @queue = ThreadSafe::Array.new

    CSV.foreach(file_to_process, 'r') do |row|
      @queue.push(row)
    end
  end

{% endhighlight %}

<p><code>App.work</code> sets up the futures creation and execution. I looped over the queue of rows and create a new <code>Worker</code> (defined below) then hand it off to the Java Future in preparation for execution. Again, the list of tasks in the queue wasn't the bottle next so enumerating over the queue was not a significant impact on the execution performance.</p>

{% highlight ruby %}

  def work
    tasks = ThreadSafe::Array.new

    executor = ThreadPoolExecutor.new(POOL_SIZE, POOL_SIZE, 60, TimeUnit::SECONDS, LinkedBlockingQueue.new)

    while @queue.size > 0
      row = @queue.pop
      email = row.shift
      task = FutureTask.new(Worker.new(email, row))
      executor.execute(task)
      tasks.push(task)
    end

{% endhighlight %}

<p>As each future completes it's work the <code>tasks</code> array enumerates the results of the worker execution. In this case I'm just writing the output to <code>STDOUT</code>.</p>

{% highlight ruby %}

    tasks.each do |t|
      result = t.get

      if result[:status] == :passed
        $stdout.puts([result[:email], result[:data]].flatten.to_csv)
      else
        $stderr.puts([result[:input], result[:data], result[:reason]].flatten.to_csv)
      end
    end

    executor.shutdown
  end

{% endhighlight %}

<p><code>Worker</code> implements the actual reason for the script. We include Java's <code>Callable</code> module so we can work with the <code>FutureTask</code> defined above.</p>

{% highlight ruby %}

  class Worker
    include java.util.concurrent.Callable

{% endhighlight %}

<p>This code is less important but represents some of the work being done. It was a rough experiment and the data was a mess. The <code>scrub_input</code> was kind of a work in progress.</p>

{% highlight ruby %}

    attr_reader :input
    attr_reader :data

    def initialize(email, data)
      @input = email
      @data = data
    end

    def scrub_input
      @input
        .sub(/^(%20|%3c|%22)+/, '')
        .sub(/^(\\)+/, '')
        .sub(/(%20|%3c|%22)+$/, '')
        .sub(/^[-.]+/, '')
        .sub(/^#+/, '')
    end

{% endhighlight %}

<p>Since the rules were being implemented in a plugin style I had a little fun with the naming. I'll leave the references up to you.</p>

{% highlight ruby %}

    def call
      email = scrub_input

      inspector = Schrute::BeetInspector.new(email, [
        Schrute::Beets::TldBeet,
        Schrute::Beets::DomainBeet,
        Schrute::Beets::LocalpartBeet,
        Schrute::Beets::SuppressionListBeet,
        Schrute::Beets::KeywordBeet,
        Schrute::Beets::TelnetBeet
      ]).call

{% endhighlight %}

<p>Here I take the result of the input inspector and format it so it can be returned and handled by the executor.</p>

{% highlight ruby %}

      status = inspector.passed? ? :passed : :failed

      {
        status: status,
        email: email,
        input: input,
        data: data,
        reason: inspector.result[:evaluation].last.reasons
      }
    end
  end
end

{% endhighlight %}

<p>Since the code was implemented in a single script file the execution is defined at the bottom.</p>

{% highlight ruby %}

file_to_process = ARGV[0]
fail "Usage: process <file_to_process.csv>" unless file_to_process

App.new(file_to_process).work
{% endhighlight %}

<p>The original <a href="https://gist.github.com/just3ws/e0c6b47f22a32ad16f1a" target="_blank">gist</a> is up on GitHub. In the end using this technique reduced a multiple hour process into a few minutes. There was some tweaking for handling particularly slow <code>Beets</code> but those were separate issues entirely.</p>
