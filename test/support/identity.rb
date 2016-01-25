class Mock::Identity < Identity
  def email
    raise NotImplementedError
  end
end
