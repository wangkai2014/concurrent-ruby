require 'concurrent/atomic/event'
require 'concurrent/executor/executor'

module Concurrent

  # An executor service which runs all operations on the current thread,
  # blocking as necessary. Operations are performed in the order they are
  # received and no two operations can be performed simultaneously.
  #
  # This executor service exists mainly for testing an debugging. When used
  # it immediately runs every `#post` operation on the current thread, blocking
  # that thread until the operation is complete. This can be very beneficial
  # during testing because it makes all operations deterministic.
  #
  # @note Intended for use primarily in testing and debugging.
  class ImmediateExecutor
    include SerialExecutor

    # Creates a new executor
    def initialize
      @stopped = Concurrent::Event.new
    end

    # @!macro executor_method_post
    def post(*args, &task)
      raise ArgumentError.new('no block given') unless block_given?
      return false unless running?
      task.call(*args)
      true
    end

    # @!macro executor_method_left_shift
    def <<(task)
      post(&task)
      self
    end

    # @!macro executor_method_running_question
    def running?
      ! shutdown?
    end

    # @!macro executor_method_shuttingdown_question
    def shuttingdown?
      false
    end

    # @!macro executor_method_shutdown_question
    def shutdown?
      @stopped.set?
    end

    # @!macro executor_method_shutdown
    def shutdown
      @stopped.set
      true
    end
    alias_method :kill, :shutdown

    # @!macro executor_method_wait_for_termination
    def wait_for_termination(timeout = nil)
      @stopped.wait(timeout)
    end
  end
end
