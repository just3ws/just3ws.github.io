---
title: Leverage the "J" in JRuby for Powerful Concurrency
---

<script src="https://gist.github.com/just3ws/e0c6b47f22a32ad16f1a" target="_blank"></script>

{% highlight ruby linenos %}
#!/usr/bin/env jruby

require_relative '../lib/schrute'

require 'csv'
require 'thread_safe'

java_import java.util.concurrent.Callable
java_import java.util.concurrent.Executors
java_import java.util.concurrent.FutureTask
java_import java.util.concurrent.LinkedBlockingQueue
java_import java.util.concurrent.ThreadPoolExecutor
java_import java.util.concurrent.TimeUnit

POOL_SIZE = java.lang.Runtime.getRuntime.availableProcessors * java.lang.Runtime.getRuntime.availableProcessors

class App
  def initialize(file_to_process)
    @queue = ThreadSafe::Array.new

    CSV.foreach(file_to_process, 'r') do |row|
      @queue.push(row)
    end
  end

  def work
    tasks =  ThreadSafe::Array.new

    executor = ThreadPoolExecutor.new(POOL_SIZE, POOL_SIZE, 60, TimeUnit::SECONDS, LinkedBlockingQueue.new)

    while @queue.size > 0
      row = @queue.pop
      email = row.shift
      task = FutureTask.new(Worker.new(email, row))
      executor.execute(task)
      tasks.push(task)
    end

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

  class Worker
    include java.util.concurrent.Callable

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

file_to_process = ARGV[0]
fail "Usage: process <file_to_process.csv>" unless file_to_process

App.new(file_to_process).work
{% endhighlight %}


