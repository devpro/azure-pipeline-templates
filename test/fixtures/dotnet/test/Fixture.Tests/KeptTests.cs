using Xunit;

namespace Fixture.Tests.Kept;

public class KeptTests
{
    [Fact]
    public void Passes() => Assert.Equal("Hello", Fixture.Library.Greeting.Hello());
}
