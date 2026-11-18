using Xunit;

namespace Fixture.Tests.Kept;

// Passes only when the job ran the steps of the beforeBuildSteps parameter, which set this variable.
public class BeforeBuildStepsTests
{
    [Fact]
    public void StepsRan() => Assert.Equal("ran", Environment.GetEnvironmentVariable("FIXTURE_BEFORE_BUILD_STEPS"));
}
