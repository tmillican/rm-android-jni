class MainActivity < Android::App::Activity
  def onCreate(savedInstanceState)
    super
    puts stringFromJNI
  end
end
