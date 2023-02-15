
/*
public class Memoizer<T, R> {
  private final Map<T, R> cache = new HashMap<>();
  private final Function<T, R> function;

  public Memoizer(Function<T, R> function) {
    this.function = function;
  }

  public R apply(T t) {
    return cache.computeIfAbsent(t, function);
  }
}*/



// Memoize the open simplex noise
