Facter.add(:qualys, type: :aggregate) do
  chunk(:hostid) do
    {
      hostid: File.read('/etc/qualys/hostid').chomp,
    }
  rescue Errno::ENOENT
    nil
  end
end
