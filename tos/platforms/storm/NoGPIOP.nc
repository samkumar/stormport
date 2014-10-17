module NoGPIOP
{
    provides interface GeneralIO as nullio;
}
implementation
{
  async command void nullio.set()
  {

  }
  async command void nullio.clr()
  {

  }
  async command void nullio.toggle()
  {

  }
  async command bool nullio.get()
  {
    return FALSE;
  }
  async command void nullio.makeInput()
  {

  }
  async command bool nullio.isInput()
  {
    return FALSE;
  }
  async command void nullio.makeOutput()
  {

  }
  async command bool nullio.isOutput()
  {
    return FALSE;
  }
}