require 'celluloid'
require_relative 'celluloid_linking'

class Financier
  include Celluloid

  trap_exit :actor_died

  def actor_died(actor, reason)
    print "#{actor.inspect} failed with exception #{reason.message}\n"
  end

  def update(*queries)
    @minions = queries.collect do |query|
      minion = FinanceActor.new(query)
      self.link(minion)
      minion.async.update
      minion
    end
  end

  def suggested_symbols
    @minions.reduce([]) do |collection, minion|
      collection + minion.suggested_symbols
    end
  end
end

financier = Financier.new
financier.async.update('YAHOO', 'Microsoft', 'google', 'die! die! die!') #=> nil

# do important stuff...
#>>   E, [2013-10-17T07:04:11.559228 #16865] ERROR -- : FinanceActor crashed!
#>> ... stack trace ...
#>> #<Celluloid::ActorProxy(FinanceActor) dead> failed with exception bad URI...
