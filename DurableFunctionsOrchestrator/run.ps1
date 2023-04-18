param($Context)

$output = @()

# Printing
Write-Host "Input: $($Context.Input). InstanceId $($Context.InstanceId). IsReplaying $($Context.IsReplaying). IsReplaying $($Context.CurrentUtcDateTime)"

# Function chaining
$output += Invoke-DurableActivity -FunctionName 'Hello' -Input 'Tokyo'
$output += Invoke-DurableActivity -FunctionName 'Hello' -Input 'Seattle'
$output += Invoke-DurableActivity -FunctionName 'Hello' -Input 'London'

# Fan-out/Fan-in (notice the -NoWait, that means the tasks are not 'awaited')
$tasks = @()
$tasks += Invoke-DurableActivity -FunctionName "Hello" -Input "Lima" -NoWait
$tasks += Invoke-DurableActivity -FunctionName "Hello" -Input "Konoha" -NoWait
$output += Wait-DurableTask -Task $tasks # add -Any to make it into WhenAny

# Retrieve an individual task's result
$result = Get-DurableTaskResult -Task $tasks[1]
Write-Host "---------------------------" + $result

# Retries
$retryOptions = New-DurableRetryOptions -FirstRetryInterval (New-Timespan -Seconds 2) -MaxNumberOfAttempts 5
$inputData = @{ Name = 'Toronto'; StartTime = $Context.CurrentUtcDateTime }
$output += Invoke-DurableActivity -FunctionName "Hello" -Input ", who is this?" -RetryOptions $retryOptions

# Custom status
Set-DurableCustomStatus -CustomStatus 'こんにちは、デビッドです'

# External event
#Start-DurableExternalEventListener -EventName "Approval"

# Timer
Start-DurableTimer -Duration (New-TimeSpan -Seconds 5)

# SubOrchestrator
$output += Invoke-DurableSubOrchestrator -FunctionName "SimpleOrch" -Input "Geneva" # -InstanceId "xxxx"

# final expression is the return statement
$output
