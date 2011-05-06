class Object
  @@justifiable_message_length = 40
  
  cattr_writer :justifiable_message_length
  
  def notify msg, target
    puts (msg + '...').ljust(@@justifiable_message_length) + target.to_s
  end
end
