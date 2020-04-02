# ExchangeServerComponentMonitor

1.0 2/19/2019 - Initial Release

While working a case, a customer had asked if we had any tools or utilities that actively monitor Exchange server components. I couldn't think of any off hand outside of just running Get-ServerComponentState, and I thought it would be a nice utility to have to monitor either all server components, or an individual component as well as having the ability of the utility to message you (or someone you designate) in case the component state changes to something other than "Active".

 

For monitoring all components its more of a passive monitor, just displaying the current component states of the server you designate to monitor. Some components by default are set to inactive, and some environments disable components, so I didn't really have an efficient way of monitoring all components for an explicit state change. So there is no notification with that monitor.

 

The individual component monitor will ask what server you want to monitor, as well as what individual component. If you want to monitor more than one component, you'll need to run a second instance of the script. I may add the functionality to monitor more than one component later when and if I can get time to test it. As of now it will monitor a single component and if configured properly will send you an email when a component state has changed. I have tested with Outlook.com (ideally you should probably technically use a 3rd party to send mail through, just in case the component that is failing does happen to cause mail flow to break) successfully.

 

# Requirements: 

Powershell 3.0, and run on an Exchange server, or an Exchange tools server in order to access the Exchange Management Shell.
