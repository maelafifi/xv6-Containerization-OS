
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 c0 10 00       	mov    $0x10c000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 30 e9 10 80       	mov    $0x8010e930,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 ae 3b 10 80       	mov    $0x80103bae,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 08 9b 10 	movl   $0x80109b08,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100049:	e8 04 56 00 00       	call   80105652 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 8c 30 11 80 3c 	movl   $0x8011303c,0x8011308c
80100055:	30 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 90 30 11 80 3c 	movl   $0x8011303c,0x80113090
8010005f:	30 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 74 e9 10 80 	movl   $0x8010e974,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 90 30 11 80    	mov    0x80113090,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 3c 30 11 80 	movl   $0x8011303c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 0f 9b 10 	movl   $0x80109b0f,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 7d 54 00 00       	call   80105514 <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 90 30 11 80       	mov    0x80113090,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 90 30 11 80       	mov    %eax,0x80113090

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 3c 30 11 80 	cmpl   $0x8011303c,-0xc(%ebp)
801000b8:	72 b1                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ba:	c9                   	leave  
801000bb:	c3                   	ret    

801000bc <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
801000c9:	e8 a5 55 00 00       	call   80105673 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 90 30 11 80       	mov    0x80113090,%eax
801000d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d6:	eb 50                	jmp    80100128 <bget+0x6c>
    if(b->dev == dev && b->blockno == blockno){
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 04             	mov    0x4(%eax),%eax
801000de:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e1:	75 3c                	jne    8010011f <bget+0x63>
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 40 08             	mov    0x8(%eax),%eax
801000e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000ec:	75 31                	jne    8010011f <bget+0x63>
      b->refcnt++;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801000f4:	8d 50 01             	lea    0x1(%eax),%edx
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
801000fd:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100104:	e8 d4 55 00 00       	call   801056dd <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 37 54 00 00       	call   8010554e <acquiresleep>
      return b;
80100117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011a:	e9 94 00 00 00       	jmp    801001b3 <bget+0xf7>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010011f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100122:	8b 40 54             	mov    0x54(%eax),%eax
80100125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100128:	81 7d f4 3c 30 11 80 	cmpl   $0x8011303c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 8c 30 11 80       	mov    0x8011308c,%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	eb 63                	jmp    8010019e <bget+0xe2>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100141:	85 c0                	test   %eax,%eax
80100143:	75 50                	jne    80100195 <bget+0xd9>
80100145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100148:	8b 00                	mov    (%eax),%eax
8010014a:	83 e0 04             	and    $0x4,%eax
8010014d:	85 c0                	test   %eax,%eax
8010014f:	75 44                	jne    80100195 <bget+0xd9>
      b->dev = dev;
80100151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100154:	8b 55 08             	mov    0x8(%ebp),%edx
80100157:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100160:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
8010017d:	e8 5b 55 00 00       	call   801056dd <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 be 53 00 00       	call   8010554e <acquiresleep>
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1e                	jmp    801001b3 <bget+0xf7>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 50             	mov    0x50(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 3c 30 11 80 	cmpl   $0x8011303c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 16 9b 10 80 	movl   $0x80109b16,(%esp)
801001ae:	e8 a1 03 00 00       	call   80100554 <panic>
}
801001b3:	c9                   	leave  
801001b4:	c3                   	ret    

801001b5 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b5:	55                   	push   %ebp
801001b6:	89 e5                	mov    %esp,%ebp
801001b8:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801001be:	89 44 24 04          	mov    %eax,0x4(%esp)
801001c2:	8b 45 08             	mov    0x8(%ebp),%eax
801001c5:	89 04 24             	mov    %eax,(%esp)
801001c8:	e8 ef fe ff ff       	call   801000bc <bget>
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0b                	jne    801001e7 <bread+0x32>
    iderw(b);
801001dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001df:	89 04 24             	mov    %eax,(%esp)
801001e2:	e8 ce 29 00 00       	call   80102bb5 <iderw>
  }
  return b;
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ea:	c9                   	leave  
801001eb:	c3                   	ret    

801001ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001ec:	55                   	push   %ebp
801001ed:	89 e5                	mov    %esp,%ebp
801001ef:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
801001f2:	8b 45 08             	mov    0x8(%ebp),%eax
801001f5:	83 c0 0c             	add    $0xc,%eax
801001f8:	89 04 24             	mov    %eax,(%esp)
801001fb:	e8 eb 53 00 00       	call   801055eb <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 27 9b 10 80 	movl   $0x80109b27,(%esp)
8010020b:	e8 44 03 00 00       	call   80100554 <panic>
  b->flags |= B_DIRTY;
80100210:	8b 45 08             	mov    0x8(%ebp),%eax
80100213:	8b 00                	mov    (%eax),%eax
80100215:	83 c8 04             	or     $0x4,%eax
80100218:	89 c2                	mov    %eax,%edx
8010021a:	8b 45 08             	mov    0x8(%ebp),%eax
8010021d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	89 04 24             	mov    %eax,(%esp)
80100225:	e8 8b 29 00 00       	call   80102bb5 <iderw>
}
8010022a:	c9                   	leave  
8010022b:	c3                   	ret    

8010022c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022c:	55                   	push   %ebp
8010022d:	89 e5                	mov    %esp,%ebp
8010022f:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
80100232:	8b 45 08             	mov    0x8(%ebp),%eax
80100235:	83 c0 0c             	add    $0xc,%eax
80100238:	89 04 24             	mov    %eax,(%esp)
8010023b:	e8 ab 53 00 00       	call   801055eb <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 2e 9b 10 80 	movl   $0x80109b2e,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 4b 53 00 00       	call   801055a9 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
80100265:	e8 09 54 00 00       	call   80105673 <acquire>
  b->refcnt--;
8010026a:	8b 45 08             	mov    0x8(%ebp),%eax
8010026d:	8b 40 4c             	mov    0x4c(%eax),%eax
80100270:	8d 50 ff             	lea    -0x1(%eax),%edx
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010027f:	85 c0                	test   %eax,%eax
80100281:	75 47                	jne    801002ca <brelse+0x9e>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100283:	8b 45 08             	mov    0x8(%ebp),%eax
80100286:	8b 40 54             	mov    0x54(%eax),%eax
80100289:	8b 55 08             	mov    0x8(%ebp),%edx
8010028c:	8b 52 50             	mov    0x50(%edx),%edx
8010028f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	8b 40 50             	mov    0x50(%eax),%eax
80100298:	8b 55 08             	mov    0x8(%ebp),%edx
8010029b:	8b 52 54             	mov    0x54(%edx),%edx
8010029e:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002a1:	8b 15 90 30 11 80    	mov    0x80113090,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 3c 30 11 80 	movl   $0x8011303c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 90 30 11 80       	mov    0x80113090,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 90 30 11 80       	mov    %eax,0x80113090
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 40 e9 10 80 	movl   $0x8010e940,(%esp)
801002d1:	e8 07 54 00 00       	call   801056dd <release>
}
801002d6:	c9                   	leave  
801002d7:	c3                   	ret    

801002d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 14             	sub    $0x14,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801002e8:	89 c2                	mov    %eax,%edx
801002ea:	ec                   	in     (%dx),%al
801002eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ee:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801002f1:	c9                   	leave  
801002f2:	c3                   	ret    

801002f3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f3:	55                   	push   %ebp
801002f4:	89 e5                	mov    %esp,%ebp
801002f6:	83 ec 08             	sub    $0x8,%esp
801002f9:	8b 45 08             	mov    0x8(%ebp),%eax
801002fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801002ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100303:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100306:	8a 45 f8             	mov    -0x8(%ebp),%al
80100309:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100312:	fa                   	cli    
}
80100313:	5d                   	pop    %ebp
80100314:	c3                   	ret    

80100315 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100315:	55                   	push   %ebp
80100316:	89 e5                	mov    %esp,%ebp
80100318:	56                   	push   %esi
80100319:	53                   	push   %ebx
8010031a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100321:	74 1c                	je     8010033f <printint+0x2a>
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	c1 e8 1f             	shr    $0x1f,%eax
80100329:	0f b6 c0             	movzbl %al,%eax
8010032c:	89 45 10             	mov    %eax,0x10(%ebp)
8010032f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100333:	74 0a                	je     8010033f <printint+0x2a>
    x = -xx;
80100335:	8b 45 08             	mov    0x8(%ebp),%eax
80100338:	f7 d8                	neg    %eax
8010033a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033d:	eb 06                	jmp    80100345 <printint+0x30>
  else
    x = xx;
8010033f:	8b 45 08             	mov    0x8(%ebp),%eax
80100342:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010034f:	8d 41 01             	lea    0x1(%ecx),%eax
80100352:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100355:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 f3                	div    %ebx
80100362:	89 d0                	mov    %edx,%eax
80100364:	8a 80 08 b0 10 80    	mov    -0x7fef4ff8(%eax),%al
8010036a:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010036e:	8b 75 0c             	mov    0xc(%ebp),%esi
80100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100374:	ba 00 00 00 00       	mov    $0x0,%edx
80100379:	f7 f6                	div    %esi
8010037b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100382:	75 c8                	jne    8010034c <printint+0x37>

  if(sign)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 10                	je     8010039a <printint+0x85>
    buf[i++] = '-';
8010038a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038d:	8d 50 01             	lea    0x1(%eax),%edx
80100390:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100393:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100398:	eb 17                	jmp    801003b1 <printint+0x9c>
8010039a:	eb 15                	jmp    801003b1 <printint+0x9c>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	8a 00                	mov    (%eax),%al
801003a6:	0f be c0             	movsbl %al,%eax
801003a9:	89 04 24             	mov    %eax,(%esp)
801003ac:	e8 b7 03 00 00       	call   80100768 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b1:	ff 4d f4             	decl   -0xc(%ebp)
801003b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003b8:	79 e2                	jns    8010039c <printint+0x87>
    consputc(buf[i]);
}
801003ba:	83 c4 30             	add    $0x30,%esp
801003bd:	5b                   	pop    %ebx
801003be:	5e                   	pop    %esi
801003bf:	5d                   	pop    %ebp
801003c0:	c3                   	ret    

801003c1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c1:	55                   	push   %ebp
801003c2:	89 e5                	mov    %esp,%ebp
801003c4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003c7:	a1 d4 d8 10 80       	mov    0x8010d8d4,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
801003dc:	e8 92 52 00 00       	call   80105673 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 35 9b 10 80 	movl   $0x80109b35,(%esp)
801003ef:	e8 60 01 00 00       	call   80100554 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003f4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100401:	e9 1b 01 00 00       	jmp    80100521 <cprintf+0x160>
    if(c != '%'){
80100406:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010040a:	74 10                	je     8010041c <cprintf+0x5b>
      consputc(c);
8010040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010040f:	89 04 24             	mov    %eax,(%esp)
80100412:	e8 51 03 00 00       	call   80100768 <consputc>
      continue;
80100417:	e9 02 01 00 00       	jmp    8010051e <cprintf+0x15d>
    }
    c = fmt[++i] & 0xff;
8010041c:	8b 55 08             	mov    0x8(%ebp),%edx
8010041f:	ff 45 f4             	incl   -0xc(%ebp)
80100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100425:	01 d0                	add    %edx,%eax
80100427:	8a 00                	mov    (%eax),%al
80100429:	0f be c0             	movsbl %al,%eax
8010042c:	25 ff 00 00 00       	and    $0xff,%eax
80100431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100438:	75 05                	jne    8010043f <cprintf+0x7e>
      break;
8010043a:	e9 01 01 00 00       	jmp    80100540 <cprintf+0x17f>
    switch(c){
8010043f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100442:	83 f8 70             	cmp    $0x70,%eax
80100445:	74 4f                	je     80100496 <cprintf+0xd5>
80100447:	83 f8 70             	cmp    $0x70,%eax
8010044a:	7f 13                	jg     8010045f <cprintf+0x9e>
8010044c:	83 f8 25             	cmp    $0x25,%eax
8010044f:	0f 84 a3 00 00 00    	je     801004f8 <cprintf+0x137>
80100455:	83 f8 64             	cmp    $0x64,%eax
80100458:	74 14                	je     8010046e <cprintf+0xad>
8010045a:	e9 a7 00 00 00       	jmp    80100506 <cprintf+0x145>
8010045f:	83 f8 73             	cmp    $0x73,%eax
80100462:	74 57                	je     801004bb <cprintf+0xfa>
80100464:	83 f8 78             	cmp    $0x78,%eax
80100467:	74 2d                	je     80100496 <cprintf+0xd5>
80100469:	e9 98 00 00 00       	jmp    80100506 <cprintf+0x145>
    case 'd':
      printint(*argp++, 10, 1);
8010046e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100471:	8d 50 04             	lea    0x4(%eax),%edx
80100474:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100477:	8b 00                	mov    (%eax),%eax
80100479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100480:	00 
80100481:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100488:	00 
80100489:	89 04 24             	mov    %eax,(%esp)
8010048c:	e8 84 fe ff ff       	call   80100315 <printint>
      break;
80100491:	e9 88 00 00 00       	jmp    8010051e <cprintf+0x15d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8d 50 04             	lea    0x4(%eax),%edx
8010049c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049f:	8b 00                	mov    (%eax),%eax
801004a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801004a8:	00 
801004a9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801004b0:	00 
801004b1:	89 04 24             	mov    %eax,(%esp)
801004b4:	e8 5c fe ff ff       	call   80100315 <printint>
      break;
801004b9:	eb 63                	jmp    8010051e <cprintf+0x15d>
    case 's':
      if((s = (char*)*argp++) == 0)
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cd:	75 09                	jne    801004d8 <cprintf+0x117>
        s = "(null)";
801004cf:	c7 45 ec 3e 9b 10 80 	movl   $0x80109b3e,-0x14(%ebp)
      for(; *s; s++)
801004d6:	eb 15                	jmp    801004ed <cprintf+0x12c>
801004d8:	eb 13                	jmp    801004ed <cprintf+0x12c>
        consputc(*s);
801004da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004dd:	8a 00                	mov    (%eax),%al
801004df:	0f be c0             	movsbl %al,%eax
801004e2:	89 04 24             	mov    %eax,(%esp)
801004e5:	e8 7e 02 00 00       	call   80100768 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004ea:	ff 45 ec             	incl   -0x14(%ebp)
801004ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f0:	8a 00                	mov    (%eax),%al
801004f2:	84 c0                	test   %al,%al
801004f4:	75 e4                	jne    801004da <cprintf+0x119>
        consputc(*s);
      break;
801004f6:	eb 26                	jmp    8010051e <cprintf+0x15d>
    case '%':
      consputc('%');
801004f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ff:	e8 64 02 00 00       	call   80100768 <consputc>
      break;
80100504:	eb 18                	jmp    8010051e <cprintf+0x15d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100506:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010050d:	e8 56 02 00 00       	call   80100768 <consputc>
      consputc(c);
80100512:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100515:	89 04 24             	mov    %eax,(%esp)
80100518:	e8 4b 02 00 00       	call   80100768 <consputc>
      break;
8010051d:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010051e:	ff 45 f4             	incl   -0xc(%ebp)
80100521:	8b 55 08             	mov    0x8(%ebp),%edx
80100524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100527:	01 d0                	add    %edx,%eax
80100529:	8a 00                	mov    (%eax),%al
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	25 ff 00 00 00       	and    $0xff,%eax
80100533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100536:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010053a:	0f 85 c6 fe ff ff    	jne    80100406 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100540:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100544:	74 0c                	je     80100552 <cprintf+0x191>
    release(&cons.lock);
80100546:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
8010054d:	e8 8b 51 00 00       	call   801056dd <release>
}
80100552:	c9                   	leave  
80100553:	c3                   	ret    

80100554 <panic>:

void
panic(char *s)
{
80100554:	55                   	push   %ebp
80100555:	89 e5                	mov    %esp,%ebp
80100557:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
8010055a:	e8 b0 fd ff ff       	call   8010030f <cli>
  cons.locking = 0;
8010055f:	c7 05 d4 d8 10 80 00 	movl   $0x0,0x8010d8d4
80100566:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100569:	e8 13 2e 00 00       	call   80103381 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 45 9b 10 80 	movl   $0x80109b45,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 59 9b 10 80 	movl   $0x80109b59,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 83 51 00 00       	call   8010572a <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 5b 9b 10 80 	movl   $0x80109b5b,(%esp)
801005c2:	e8 fa fd ff ff       	call   801003c1 <cprintf>
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005c7:	ff 45 f4             	incl   -0xc(%ebp)
801005ca:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005ce:	7e e0                	jle    801005b0 <panic+0x5c>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005d0:	c7 05 8c d8 10 80 01 	movl   $0x1,0x8010d88c
801005d7:	00 00 00 
  for(;;)
    ;
801005da:	eb fe                	jmp    801005da <panic+0x86>

801005dc <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005dc:	55                   	push   %ebp
801005dd:	89 e5                	mov    %esp,%ebp
801005df:	83 ec 28             	sub    $0x28,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005e2:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005e9:	00 
801005ea:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005f1:	e8 fd fc ff ff       	call   801002f3 <outb>
  pos = inb(CRTPORT+1) << 8;
801005f6:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005fd:	e8 d6 fc ff ff       	call   801002d8 <inb>
80100602:	0f b6 c0             	movzbl %al,%eax
80100605:	c1 e0 08             	shl    $0x8,%eax
80100608:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010060b:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100612:	00 
80100613:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010061a:	e8 d4 fc ff ff       	call   801002f3 <outb>
  pos |= inb(CRTPORT+1);
8010061f:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100626:	e8 ad fc ff ff       	call   801002d8 <inb>
8010062b:	0f b6 c0             	movzbl %al,%eax
8010062e:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100631:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100635:	75 1b                	jne    80100652 <cgaputc+0x76>
    pos += 80 - pos%80;
80100637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010063a:	b9 50 00 00 00       	mov    $0x50,%ecx
8010063f:	99                   	cltd   
80100640:	f7 f9                	idiv   %ecx
80100642:	89 d0                	mov    %edx,%eax
80100644:	ba 50 00 00 00       	mov    $0x50,%edx
80100649:	29 c2                	sub    %eax,%edx
8010064b:	89 d0                	mov    %edx,%eax
8010064d:	01 45 f4             	add    %eax,-0xc(%ebp)
80100650:	eb 34                	jmp    80100686 <cgaputc+0xaa>
  else if(c == BACKSPACE){
80100652:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100659:	75 0b                	jne    80100666 <cgaputc+0x8a>
    if(pos > 0) --pos;
8010065b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010065f:	7e 25                	jle    80100686 <cgaputc+0xaa>
80100661:	ff 4d f4             	decl   -0xc(%ebp)
80100664:	eb 20                	jmp    80100686 <cgaputc+0xaa>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100666:	8b 0d 04 b0 10 80    	mov    0x8010b004,%ecx
8010066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010066f:	8d 50 01             	lea    0x1(%eax),%edx
80100672:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100675:	01 c0                	add    %eax,%eax
80100677:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067a:	8b 45 08             	mov    0x8(%ebp),%eax
8010067d:	0f b6 c0             	movzbl %al,%eax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
80100686:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068a:	78 09                	js     80100695 <cgaputc+0xb9>
8010068c:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100693:	7e 0c                	jle    801006a1 <cgaputc+0xc5>
    panic("pos under/overflow");
80100695:	c7 04 24 5f 9b 10 80 	movl   $0x80109b5f,(%esp)
8010069c:	e8 b3 fe ff ff       	call   80100554 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006a1:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006a8:	7e 53                	jle    801006fd <cgaputc+0x121>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006aa:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801006af:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b5:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801006ba:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c1:	00 
801006c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801006c6:	89 04 24             	mov    %eax,(%esp)
801006c9:	e8 d1 52 00 00       	call   8010599f <memmove>
    pos -= 80;
801006ce:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d2:	b8 80 07 00 00       	mov    $0x780,%eax
801006d7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006da:	01 c0                	add    %eax,%eax
801006dc:	8b 0d 04 b0 10 80    	mov    0x8010b004,%ecx
801006e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006e5:	01 d2                	add    %edx,%edx
801006e7:	01 ca                	add    %ecx,%edx
801006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801006ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f4:	00 
801006f5:	89 14 24             	mov    %edx,(%esp)
801006f8:	e8 d9 51 00 00       	call   801058d6 <memset>
  }

  outb(CRTPORT, 14);
801006fd:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100704:	00 
80100705:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010070c:	e8 e2 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos>>8);
80100711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100714:	c1 f8 08             	sar    $0x8,%eax
80100717:	0f b6 c0             	movzbl %al,%eax
8010071a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010071e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100725:	e8 c9 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT, 15);
8010072a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100731:	00 
80100732:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100739:	e8 b5 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos);
8010073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	89 44 24 04          	mov    %eax,0x4(%esp)
80100748:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010074f:	e8 9f fb ff ff       	call   801002f3 <outb>
  crt[pos] = ' ' | 0x0700;
80100754:	8b 15 04 b0 10 80    	mov    0x8010b004,%edx
8010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010075d:	01 c0                	add    %eax,%eax
8010075f:	01 d0                	add    %edx,%eax
80100761:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100766:	c9                   	leave  
80100767:	c3                   	ret    

80100768 <consputc>:

void
consputc(int c)
{
80100768:	55                   	push   %ebp
80100769:	89 e5                	mov    %esp,%ebp
8010076b:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
8010076e:	a1 8c d8 10 80       	mov    0x8010d88c,%eax
80100773:	85 c0                	test   %eax,%eax
80100775:	74 07                	je     8010077e <consputc+0x16>
    cli();
80100777:	e8 93 fb ff ff       	call   8010030f <cli>
    for(;;)
      ;
8010077c:	eb fe                	jmp    8010077c <consputc+0x14>
  }

  if(c == BACKSPACE){
8010077e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100785:	75 26                	jne    801007ad <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 01 72 00 00       	call   80107994 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 f5 71 00 00       	call   80107994 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 e9 71 00 00       	call   80107994 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 dc 71 00 00       	call   80107994 <uartputc>
  cgaputc(c);
801007b8:	8b 45 08             	mov    0x8(%ebp),%eax
801007bb:	89 04 24             	mov    %eax,(%esp)
801007be:	e8 19 fe ff ff       	call   801005dc <cgaputc>
}
801007c3:	c9                   	leave  
801007c4:	c3                   	ret    

801007c5 <copy_buf>:

#define C(x)  ((x)-'@')  // Control-x


void copy_buf(char *dst, char *src, int len)
{
801007c5:	55                   	push   %ebp
801007c6:	89 e5                	mov    %esp,%ebp
801007c8:	83 ec 10             	sub    $0x10,%esp
  int i;

  for (i = 0; i < len; i++) {
801007cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801007d2:	eb 17                	jmp    801007eb <copy_buf+0x26>
    dst[i] = src[i];
801007d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801007d7:	8b 45 08             	mov    0x8(%ebp),%eax
801007da:	01 c2                	add    %eax,%edx
801007dc:	8b 4d fc             	mov    -0x4(%ebp),%ecx
801007df:	8b 45 0c             	mov    0xc(%ebp),%eax
801007e2:	01 c8                	add    %ecx,%eax
801007e4:	8a 00                	mov    (%eax),%al
801007e6:	88 02                	mov    %al,(%edx)

void copy_buf(char *dst, char *src, int len)
{
  int i;

  for (i = 0; i < len; i++) {
801007e8:	ff 45 fc             	incl   -0x4(%ebp)
801007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007ee:	3b 45 10             	cmp    0x10(%ebp),%eax
801007f1:	7c e1                	jl     801007d4 <copy_buf+0xf>
    dst[i] = src[i];
  }
}
801007f3:	c9                   	leave  
801007f4:	c3                   	ret    

801007f5 <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801007f5:	55                   	push   %ebp
801007f6:	89 e5                	mov    %esp,%ebp
801007f8:	57                   	push   %edi
801007f9:	56                   	push   %esi
801007fa:	53                   	push   %ebx
801007fb:	83 ec 2c             	sub    $0x2c,%esp
  int c, doprocdump = 0, doconsoleswitch = 0;
801007fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100805:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

  acquire(&cons.lock);
8010080c:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100813:	e8 5b 4e 00 00       	call   80105673 <acquire>
  while((c = getc()) >= 0){
80100818:	e9 eb 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    switch(c){
8010081d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100820:	83 f8 14             	cmp    $0x14,%eax
80100823:	74 3b                	je     80100860 <consoleintr+0x6b>
80100825:	83 f8 14             	cmp    $0x14,%eax
80100828:	7f 13                	jg     8010083d <consoleintr+0x48>
8010082a:	83 f8 08             	cmp    $0x8,%eax
8010082d:	0f 84 16 01 00 00    	je     80100949 <consoleintr+0x154>
80100833:	83 f8 10             	cmp    $0x10,%eax
80100836:	74 1c                	je     80100854 <consoleintr+0x5f>
80100838:	e9 3c 01 00 00       	jmp    80100979 <consoleintr+0x184>
8010083d:	83 f8 15             	cmp    $0x15,%eax
80100840:	0f 84 db 00 00 00    	je     80100921 <consoleintr+0x12c>
80100846:	83 f8 7f             	cmp    $0x7f,%eax
80100849:	0f 84 fa 00 00 00    	je     80100949 <consoleintr+0x154>
8010084f:	e9 25 01 00 00       	jmp    80100979 <consoleintr+0x184>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      // cprintf("PID of myPROC is %d\n.", myproc()->pid);
      doprocdump = 1;
80100854:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      break;
8010085b:	e9 a8 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('T'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      if (active+1 > MAX_VC){
80100860:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100865:	40                   	inc    %eax
80100866:	83 f8 04             	cmp    $0x4,%eax
80100869:	7e 23                	jle    8010088e <consoleintr+0x99>
        active = 1;
8010086b:	c7 05 00 b0 10 80 01 	movl   $0x1,0x8010b000
80100872:	00 00 00 
        input = buf1;
80100875:	ba a0 32 11 80       	mov    $0x801132a0,%edx
8010087a:	bb 20 d6 10 80       	mov    $0x8010d620,%ebx
8010087f:	b8 23 00 00 00       	mov    $0x23,%eax
80100884:	89 d7                	mov    %edx,%edi
80100886:	89 de                	mov    %ebx,%esi
80100888:	89 c1                	mov    %eax,%ecx
8010088a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
8010088c:	eb 6e                	jmp    801008fc <consoleintr+0x107>
      } else{
        active = active + 1;
8010088e:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100893:	40                   	inc    %eax
80100894:	a3 00 b0 10 80       	mov    %eax,0x8010b000
        if(active == 2){
80100899:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010089e:	83 f8 02             	cmp    $0x2,%eax
801008a1:	75 17                	jne    801008ba <consoleintr+0xc5>
          buf2 = input;
801008a3:	ba c0 d6 10 80       	mov    $0x8010d6c0,%edx
801008a8:	bb a0 32 11 80       	mov    $0x801132a0,%ebx
801008ad:	b8 23 00 00 00       	mov    $0x23,%eax
801008b2:	89 d7                	mov    %edx,%edi
801008b4:	89 de                	mov    %ebx,%esi
801008b6:	89 c1                	mov    %eax,%ecx
801008b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
        if(active == 3){
801008ba:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801008bf:	83 f8 03             	cmp    $0x3,%eax
801008c2:	75 17                	jne    801008db <consoleintr+0xe6>
          buf3 = input;
801008c4:	ba 60 d7 10 80       	mov    $0x8010d760,%edx
801008c9:	bb a0 32 11 80       	mov    $0x801132a0,%ebx
801008ce:	b8 23 00 00 00       	mov    $0x23,%eax
801008d3:	89 d7                	mov    %edx,%edi
801008d5:	89 de                	mov    %ebx,%esi
801008d7:	89 c1                	mov    %eax,%ecx
801008d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
        if(active == 4){
801008db:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801008e0:	83 f8 04             	cmp    $0x4,%eax
801008e3:	75 17                	jne    801008fc <consoleintr+0x107>
          buf4 = input;
801008e5:	ba 00 d8 10 80       	mov    $0x8010d800,%edx
801008ea:	bb a0 32 11 80       	mov    $0x801132a0,%ebx
801008ef:	b8 23 00 00 00       	mov    $0x23,%eax
801008f4:	89 d7                	mov    %edx,%edi
801008f6:	89 de                	mov    %ebx,%esi
801008f8:	89 c1                	mov    %eax,%ecx
801008fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        }
      }
      doconsoleswitch = 1;
801008fc:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      break;
80100903:	e9 00 01 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100908:	a1 28 33 11 80       	mov    0x80113328,%eax
8010090d:	48                   	dec    %eax
8010090e:	a3 28 33 11 80       	mov    %eax,0x80113328
        consputc(BACKSPACE);
80100913:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010091a:	e8 49 fe ff ff       	call   80100768 <consputc>
8010091f:	eb 01                	jmp    80100922 <consoleintr+0x12d>
        }
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100921:	90                   	nop
80100922:	8b 15 28 33 11 80    	mov    0x80113328,%edx
80100928:	a1 24 33 11 80       	mov    0x80113324,%eax
8010092d:	39 c2                	cmp    %eax,%edx
8010092f:	74 13                	je     80100944 <consoleintr+0x14f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100931:	a1 28 33 11 80       	mov    0x80113328,%eax
80100936:	48                   	dec    %eax
80100937:	83 e0 7f             	and    $0x7f,%eax
8010093a:	8a 80 a0 32 11 80    	mov    -0x7feecd60(%eax),%al
        }
      }
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100940:	3c 0a                	cmp    $0xa,%al
80100942:	75 c4                	jne    80100908 <consoleintr+0x113>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100944:	e9 bf 00 00 00       	jmp    80100a08 <consoleintr+0x213>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100949:	8b 15 28 33 11 80    	mov    0x80113328,%edx
8010094f:	a1 24 33 11 80       	mov    0x80113324,%eax
80100954:	39 c2                	cmp    %eax,%edx
80100956:	74 1c                	je     80100974 <consoleintr+0x17f>
        input.e--;
80100958:	a1 28 33 11 80       	mov    0x80113328,%eax
8010095d:	48                   	dec    %eax
8010095e:	a3 28 33 11 80       	mov    %eax,0x80113328
        consputc(BACKSPACE);
80100963:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010096a:	e8 f9 fd ff ff       	call   80100768 <consputc>
      }
      break;
8010096f:	e9 94 00 00 00       	jmp    80100a08 <consoleintr+0x213>
80100974:	e9 8f 00 00 00       	jmp    80100a08 <consoleintr+0x213>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100979:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010097d:	0f 84 84 00 00 00    	je     80100a07 <consoleintr+0x212>
80100983:	8b 15 28 33 11 80    	mov    0x80113328,%edx
80100989:	a1 20 33 11 80       	mov    0x80113320,%eax
8010098e:	29 c2                	sub    %eax,%edx
80100990:	89 d0                	mov    %edx,%eax
80100992:	83 f8 7f             	cmp    $0x7f,%eax
80100995:	77 70                	ja     80100a07 <consoleintr+0x212>
        c = (c == '\r') ? '\n' : c;
80100997:	83 7d dc 0d          	cmpl   $0xd,-0x24(%ebp)
8010099b:	74 05                	je     801009a2 <consoleintr+0x1ad>
8010099d:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009a0:	eb 05                	jmp    801009a7 <consoleintr+0x1b2>
801009a2:	b8 0a 00 00 00       	mov    $0xa,%eax
801009a7:	89 45 dc             	mov    %eax,-0x24(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801009aa:	a1 28 33 11 80       	mov    0x80113328,%eax
801009af:	8d 50 01             	lea    0x1(%eax),%edx
801009b2:	89 15 28 33 11 80    	mov    %edx,0x80113328
801009b8:	83 e0 7f             	and    $0x7f,%eax
801009bb:	89 c2                	mov    %eax,%edx
801009bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c0:	88 82 a0 32 11 80    	mov    %al,-0x7feecd60(%edx)
        consputc(c);
801009c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c9:	89 04 24             	mov    %eax,(%esp)
801009cc:	e8 97 fd ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009d1:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
801009d5:	74 18                	je     801009ef <consoleintr+0x1fa>
801009d7:	83 7d dc 04          	cmpl   $0x4,-0x24(%ebp)
801009db:	74 12                	je     801009ef <consoleintr+0x1fa>
801009dd:	a1 28 33 11 80       	mov    0x80113328,%eax
801009e2:	8b 15 20 33 11 80    	mov    0x80113320,%edx
801009e8:	83 ea 80             	sub    $0xffffff80,%edx
801009eb:	39 d0                	cmp    %edx,%eax
801009ed:	75 18                	jne    80100a07 <consoleintr+0x212>
          input.w = input.e;
801009ef:	a1 28 33 11 80       	mov    0x80113328,%eax
801009f4:	a3 24 33 11 80       	mov    %eax,0x80113324
          wakeup(&input.r);
801009f9:	c7 04 24 20 33 11 80 	movl   $0x80113320,(%esp)
80100a00:	e8 f5 45 00 00       	call   80104ffa <wakeup>
        }
      }
      break;
80100a05:	eb 00                	jmp    80100a07 <consoleintr+0x212>
80100a07:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0, doconsoleswitch = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100a08:	8b 45 08             	mov    0x8(%ebp),%eax
80100a0b:	ff d0                	call   *%eax
80100a0d:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100a10:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80100a14:	0f 89 03 fe ff ff    	jns    8010081d <consoleintr+0x28>
        }
      }
      break;
    }
  }
  release(&cons.lock);
80100a1a:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100a21:	e8 b7 4c 00 00       	call   801056dd <release>
  if(doprocdump){
80100a26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a2a:	74 1d                	je     80100a49 <consoleintr+0x254>
    cprintf("aout to call procdump.\n");
80100a2c:	c7 04 24 72 9b 10 80 	movl   $0x80109b72,(%esp)
80100a33:	e8 89 f9 ff ff       	call   801003c1 <cprintf>
    procdump();  // now call procdump() wo. cons.lock held
80100a38:	e8 c7 46 00 00       	call   80105104 <procdump>
    cprintf("after the call procdump.\n");
80100a3d:	c7 04 24 8a 9b 10 80 	movl   $0x80109b8a,(%esp)
80100a44:	e8 78 f9 ff ff       	call   801003c1 <cprintf>

  }
  if(doconsoleswitch){
80100a49:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a4d:	74 15                	je     80100a64 <consoleintr+0x26f>
    cprintf("\nActive console now: %d\n", active);
80100a4f:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100a54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a58:	c7 04 24 a4 9b 10 80 	movl   $0x80109ba4,(%esp)
80100a5f:	e8 5d f9 ff ff       	call   801003c1 <cprintf>
  }
}
80100a64:	83 c4 2c             	add    $0x2c,%esp
80100a67:	5b                   	pop    %ebx
80100a68:	5e                   	pop    %esi
80100a69:	5f                   	pop    %edi
80100a6a:	5d                   	pop    %ebp
80100a6b:	c3                   	ret    

80100a6c <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a6c:	55                   	push   %ebp
80100a6d:	89 e5                	mov    %esp,%ebp
80100a6f:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100a72:	8b 45 08             	mov    0x8(%ebp),%eax
80100a75:	89 04 24             	mov    %eax,(%esp)
80100a78:	e8 b4 11 00 00       	call   80101c31 <iunlock>
  target = n;
80100a7d:	8b 45 10             	mov    0x10(%ebp),%eax
80100a80:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a83:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100a8a:	e8 e4 4b 00 00       	call   80105673 <acquire>
  while(n > 0){
80100a8f:	e9 b7 00 00 00       	jmp    80100b4b <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a94:	eb 41                	jmp    80100ad7 <consoleread+0x6b>
      if(myproc()->killed){
80100a96:	e8 30 3b 00 00       	call   801045cb <myproc>
80100a9b:	8b 40 24             	mov    0x24(%eax),%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 21                	je     80100ac3 <consoleread+0x57>
        release(&cons.lock);
80100aa2:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100aa9:	e8 2f 4c 00 00       	call   801056dd <release>
        ilock(ip);
80100aae:	8b 45 08             	mov    0x8(%ebp),%eax
80100ab1:	89 04 24             	mov    %eax,(%esp)
80100ab4:	e8 6e 10 00 00       	call   80101b27 <ilock>
        return -1;
80100ab9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100abe:	e9 b3 00 00 00       	jmp    80100b76 <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100ac3:	c7 44 24 04 a0 d8 10 	movl   $0x8010d8a0,0x4(%esp)
80100aca:	80 
80100acb:	c7 04 24 20 33 11 80 	movl   $0x80113320,(%esp)
80100ad2:	e8 4c 44 00 00       	call   80104f23 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100ad7:	8b 15 20 33 11 80    	mov    0x80113320,%edx
80100add:	a1 24 33 11 80       	mov    0x80113324,%eax
80100ae2:	39 c2                	cmp    %eax,%edx
80100ae4:	74 b0                	je     80100a96 <consoleread+0x2a>
80100ae6:	8b 45 08             	mov    0x8(%ebp),%eax
80100ae9:	8b 40 54             	mov    0x54(%eax),%eax
80100aec:	0f bf d0             	movswl %ax,%edx
80100aef:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100af4:	39 c2                	cmp    %eax,%edx
80100af6:	75 9e                	jne    80100a96 <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100af8:	a1 20 33 11 80       	mov    0x80113320,%eax
80100afd:	8d 50 01             	lea    0x1(%eax),%edx
80100b00:	89 15 20 33 11 80    	mov    %edx,0x80113320
80100b06:	83 e0 7f             	and    $0x7f,%eax
80100b09:	8a 80 a0 32 11 80    	mov    -0x7feecd60(%eax),%al
80100b0f:	0f be c0             	movsbl %al,%eax
80100b12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100b15:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100b19:	75 17                	jne    80100b32 <consoleread+0xc6>
      if(n < target){
80100b1b:	8b 45 10             	mov    0x10(%ebp),%eax
80100b1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100b21:	73 0d                	jae    80100b30 <consoleread+0xc4>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100b23:	a1 20 33 11 80       	mov    0x80113320,%eax
80100b28:	48                   	dec    %eax
80100b29:	a3 20 33 11 80       	mov    %eax,0x80113320
      }
      break;
80100b2e:	eb 25                	jmp    80100b55 <consoleread+0xe9>
80100b30:	eb 23                	jmp    80100b55 <consoleread+0xe9>
    }
    *dst++ = c;
80100b32:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b35:	8d 50 01             	lea    0x1(%eax),%edx
80100b38:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b3b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b3e:	88 10                	mov    %dl,(%eax)
    --n;
80100b40:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
80100b43:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b47:	75 02                	jne    80100b4b <consoleread+0xdf>
      break;
80100b49:	eb 0a                	jmp    80100b55 <consoleread+0xe9>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b4f:	0f 8f 3f ff ff ff    	jg     80100a94 <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100b55:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100b5c:	e8 7c 4b 00 00       	call   801056dd <release>
  ilock(ip);
80100b61:	8b 45 08             	mov    0x8(%ebp),%eax
80100b64:	89 04 24             	mov    %eax,(%esp)
80100b67:	e8 bb 0f 00 00       	call   80101b27 <ilock>

  return target - n;
80100b6c:	8b 45 10             	mov    0x10(%ebp),%eax
80100b6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b72:	29 c2                	sub    %eax,%edx
80100b74:	89 d0                	mov    %edx,%eax
}
80100b76:	c9                   	leave  
80100b77:	c3                   	ret    

80100b78 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b78:	55                   	push   %ebp
80100b79:	89 e5                	mov    %esp,%ebp
80100b7b:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (active == ip->minor){
80100b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80100b81:	8b 40 54             	mov    0x54(%eax),%eax
80100b84:	0f bf d0             	movswl %ax,%edx
80100b87:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80100b8c:	39 c2                	cmp    %eax,%edx
80100b8e:	75 5a                	jne    80100bea <consolewrite+0x72>
    iunlock(ip);
80100b90:	8b 45 08             	mov    0x8(%ebp),%eax
80100b93:	89 04 24             	mov    %eax,(%esp)
80100b96:	e8 96 10 00 00       	call   80101c31 <iunlock>
    acquire(&cons.lock);
80100b9b:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100ba2:	e8 cc 4a 00 00       	call   80105673 <acquire>
    for(i = 0; i < n; i++)
80100ba7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100bae:	eb 1b                	jmp    80100bcb <consolewrite+0x53>
      consputc(buf[i] & 0xff);
80100bb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100bb3:	8b 45 0c             	mov    0xc(%ebp),%eax
80100bb6:	01 d0                	add    %edx,%eax
80100bb8:	8a 00                	mov    (%eax),%al
80100bba:	0f be c0             	movsbl %al,%eax
80100bbd:	0f b6 c0             	movzbl %al,%eax
80100bc0:	89 04 24             	mov    %eax,(%esp)
80100bc3:	e8 a0 fb ff ff       	call   80100768 <consputc>
  int i;

  if (active == ip->minor){
    iunlock(ip);
    acquire(&cons.lock);
    for(i = 0; i < n; i++)
80100bc8:	ff 45 f4             	incl   -0xc(%ebp)
80100bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100bce:	3b 45 10             	cmp    0x10(%ebp),%eax
80100bd1:	7c dd                	jl     80100bb0 <consolewrite+0x38>
      consputc(buf[i] & 0xff);
    release(&cons.lock);
80100bd3:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100bda:	e8 fe 4a 00 00       	call   801056dd <release>
    ilock(ip);
80100bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80100be2:	89 04 24             	mov    %eax,(%esp)
80100be5:	e8 3d 0f 00 00       	call   80101b27 <ilock>
  }
  return n;
80100bea:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bed:	c9                   	leave  
80100bee:	c3                   	ret    

80100bef <consoleinit>:

void
consoleinit(void)
{
80100bef:	55                   	push   %ebp
80100bf0:	89 e5                	mov    %esp,%ebp
80100bf2:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100bf5:	c7 44 24 04 bd 9b 10 	movl   $0x80109bbd,0x4(%esp)
80100bfc:	80 
80100bfd:	c7 04 24 a0 d8 10 80 	movl   $0x8010d8a0,(%esp)
80100c04:	e8 49 4a 00 00       	call   80105652 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100c09:	c7 05 8c 3e 11 80 78 	movl   $0x80100b78,0x80113e8c
80100c10:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100c13:	c7 05 88 3e 11 80 6c 	movl   $0x80100a6c,0x80113e88
80100c1a:	0a 10 80 
  cons.locking = 1;
80100c1d:	c7 05 d4 d8 10 80 01 	movl   $0x1,0x8010d8d4
80100c24:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100c27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100c2e:	00 
80100c2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100c36:	e8 2c 21 00 00       	call   80102d67 <ioapicenable>
}
80100c3b:	c9                   	leave  
80100c3c:	c3                   	ret    
80100c3d:	00 00                	add    %al,(%eax)
	...

80100c40 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c40:	55                   	push   %ebp
80100c41:	89 e5                	mov    %esp,%ebp
80100c43:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c49:	e8 7d 39 00 00       	call   801045cb <myproc>
80100c4e:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c51:	e8 75 2c 00 00       	call   801038cb <begin_op>

  if((ip = namei(path)) == 0){
80100c56:	8b 45 08             	mov    0x8(%ebp),%eax
80100c59:	89 04 24             	mov    %eax,(%esp)
80100c5c:	e8 67 1b 00 00       	call   801027c8 <namei>
80100c61:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c64:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c68:	75 1b                	jne    80100c85 <exec+0x45>
    end_op();
80100c6a:	e8 de 2c 00 00       	call   8010394d <end_op>
    cprintf("exec: fail\n");
80100c6f:	c7 04 24 c5 9b 10 80 	movl   $0x80109bc5,(%esp)
80100c76:	e8 46 f7 ff ff       	call   801003c1 <cprintf>
    return -1;
80100c7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c80:	e9 f6 03 00 00       	jmp    8010107b <exec+0x43b>
  }
  ilock(ip);
80100c85:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c88:	89 04 24             	mov    %eax,(%esp)
80100c8b:	e8 97 0e 00 00       	call   80101b27 <ilock>
  pgdir = 0;
80100c90:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c97:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100c9e:	00 
80100c9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100ca6:	00 
80100ca7:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100cad:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cb1:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cb4:	89 04 24             	mov    %eax,(%esp)
80100cb7:	e8 02 13 00 00       	call   80101fbe <readi>
80100cbc:	83 f8 34             	cmp    $0x34,%eax
80100cbf:	74 05                	je     80100cc6 <exec+0x86>
    goto bad;
80100cc1:	e9 89 03 00 00       	jmp    8010104f <exec+0x40f>
  if(elf.magic != ELF_MAGIC)
80100cc6:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100ccc:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cd1:	74 05                	je     80100cd8 <exec+0x98>
    goto bad;
80100cd3:	e9 77 03 00 00       	jmp    8010104f <exec+0x40f>

  if((pgdir = setupkvm()) == 0)
80100cd8:	e8 99 7c 00 00       	call   80108976 <setupkvm>
80100cdd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ce0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100ce4:	75 05                	jne    80100ceb <exec+0xab>
    goto bad;
80100ce6:	e9 64 03 00 00       	jmp    8010104f <exec+0x40f>

  // Load program into memory.
  sz = 0;
80100ceb:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cf2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100cf9:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100cff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d02:	e9 fb 00 00 00       	jmp    80100e02 <exec+0x1c2>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d07:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d0a:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100d11:	00 
80100d12:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d16:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d20:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d23:	89 04 24             	mov    %eax,(%esp)
80100d26:	e8 93 12 00 00       	call   80101fbe <readi>
80100d2b:	83 f8 20             	cmp    $0x20,%eax
80100d2e:	74 05                	je     80100d35 <exec+0xf5>
      goto bad;
80100d30:	e9 1a 03 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.type != ELF_PROG_LOAD)
80100d35:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d3b:	83 f8 01             	cmp    $0x1,%eax
80100d3e:	74 05                	je     80100d45 <exec+0x105>
      continue;
80100d40:	e9 b1 00 00 00       	jmp    80100df6 <exec+0x1b6>
    if(ph.memsz < ph.filesz)
80100d45:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d4b:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d51:	39 c2                	cmp    %eax,%edx
80100d53:	73 05                	jae    80100d5a <exec+0x11a>
      goto bad;
80100d55:	e9 f5 02 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d5a:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d60:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d66:	01 c2                	add    %eax,%edx
80100d68:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d6e:	39 c2                	cmp    %eax,%edx
80100d70:	73 05                	jae    80100d77 <exec+0x137>
      goto bad;
80100d72:	e9 d8 02 00 00       	jmp    8010104f <exec+0x40f>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d77:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d7d:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d83:	01 d0                	add    %edx,%eax
80100d85:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d89:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d90:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d93:	89 04 24             	mov    %eax,(%esp)
80100d96:	e8 a7 7f 00 00       	call   80108d42 <allocuvm>
80100d9b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d9e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100da2:	75 05                	jne    80100da9 <exec+0x169>
      goto bad;
80100da4:	e9 a6 02 00 00       	jmp    8010104f <exec+0x40f>
    if(ph.vaddr % PGSIZE != 0)
80100da9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100daf:	25 ff 0f 00 00       	and    $0xfff,%eax
80100db4:	85 c0                	test   %eax,%eax
80100db6:	74 05                	je     80100dbd <exec+0x17d>
      goto bad;
80100db8:	e9 92 02 00 00       	jmp    8010104f <exec+0x40f>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100dbd:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100dc3:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100dc9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100dcf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100dd3:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100dd7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100dda:	89 54 24 08          	mov    %edx,0x8(%esp)
80100dde:	89 44 24 04          	mov    %eax,0x4(%esp)
80100de2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100de5:	89 04 24             	mov    %eax,(%esp)
80100de8:	e8 72 7e 00 00       	call   80108c5f <loaduvm>
80100ded:	85 c0                	test   %eax,%eax
80100def:	79 05                	jns    80100df6 <exec+0x1b6>
      goto bad;
80100df1:	e9 59 02 00 00       	jmp    8010104f <exec+0x40f>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100df6:	ff 45 ec             	incl   -0x14(%ebp)
80100df9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dfc:	83 c0 20             	add    $0x20,%eax
80100dff:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e02:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
80100e08:	0f b7 c0             	movzwl %ax,%eax
80100e0b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100e0e:	0f 8f f3 fe ff ff    	jg     80100d07 <exec+0xc7>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100e14:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e17:	89 04 24             	mov    %eax,(%esp)
80100e1a:	e8 07 0f 00 00       	call   80101d26 <iunlockput>
  end_op();
80100e1f:	e8 29 2b 00 00       	call   8010394d <end_op>
  ip = 0;
80100e24:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e2b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e2e:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e33:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e38:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e3b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e3e:	05 00 20 00 00       	add    $0x2000,%eax
80100e43:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e47:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e4e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e51:	89 04 24             	mov    %eax,(%esp)
80100e54:	e8 e9 7e 00 00       	call   80108d42 <allocuvm>
80100e59:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e5c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e60:	75 05                	jne    80100e67 <exec+0x227>
    goto bad;
80100e62:	e9 e8 01 00 00       	jmp    8010104f <exec+0x40f>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e6a:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e76:	89 04 24             	mov    %eax,(%esp)
80100e79:	e8 34 81 00 00       	call   80108fb2 <clearpteu>
  sp = sz;
80100e7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e81:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e84:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e8b:	e9 95 00 00 00       	jmp    80100f25 <exec+0x2e5>
    if(argc >= MAXARG)
80100e90:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e94:	76 05                	jbe    80100e9b <exec+0x25b>
      goto bad;
80100e96:	e9 b4 01 00 00       	jmp    8010104f <exec+0x40f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e9e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ea5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ea8:	01 d0                	add    %edx,%eax
80100eaa:	8b 00                	mov    (%eax),%eax
80100eac:	89 04 24             	mov    %eax,(%esp)
80100eaf:	e8 75 4c 00 00       	call   80105b29 <strlen>
80100eb4:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100eb7:	29 c2                	sub    %eax,%edx
80100eb9:	89 d0                	mov    %edx,%eax
80100ebb:	48                   	dec    %eax
80100ebc:	83 e0 fc             	and    $0xfffffffc,%eax
80100ebf:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ecf:	01 d0                	add    %edx,%eax
80100ed1:	8b 00                	mov    (%eax),%eax
80100ed3:	89 04 24             	mov    %eax,(%esp)
80100ed6:	e8 4e 4c 00 00       	call   80105b29 <strlen>
80100edb:	40                   	inc    %eax
80100edc:	89 c2                	mov    %eax,%edx
80100ede:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ee1:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eeb:	01 c8                	add    %ecx,%eax
80100eed:	8b 00                	mov    (%eax),%eax
80100eef:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100ef3:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ef7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100efa:	89 44 24 04          	mov    %eax,0x4(%esp)
80100efe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f01:	89 04 24             	mov    %eax,(%esp)
80100f04:	e8 61 82 00 00       	call   8010916a <copyout>
80100f09:	85 c0                	test   %eax,%eax
80100f0b:	79 05                	jns    80100f12 <exec+0x2d2>
      goto bad;
80100f0d:	e9 3d 01 00 00       	jmp    8010104f <exec+0x40f>
    ustack[3+argc] = sp;
80100f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f15:	8d 50 03             	lea    0x3(%eax),%edx
80100f18:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f1b:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f22:	ff 45 e4             	incl   -0x1c(%ebp)
80100f25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f28:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f2f:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f32:	01 d0                	add    %edx,%eax
80100f34:	8b 00                	mov    (%eax),%eax
80100f36:	85 c0                	test   %eax,%eax
80100f38:	0f 85 52 ff ff ff    	jne    80100e90 <exec+0x250>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f3e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f41:	83 c0 03             	add    $0x3,%eax
80100f44:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f4b:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f4f:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f56:	ff ff ff 
  ustack[1] = argc;
80100f59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f5c:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f65:	40                   	inc    %eax
80100f66:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f70:	29 d0                	sub    %edx,%eax
80100f72:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f7b:	83 c0 04             	add    $0x4,%eax
80100f7e:	c1 e0 02             	shl    $0x2,%eax
80100f81:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f84:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f87:	83 c0 04             	add    $0x4,%eax
80100f8a:	c1 e0 02             	shl    $0x2,%eax
80100f8d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100f91:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f97:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f9b:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fa2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fa5:	89 04 24             	mov    %eax,(%esp)
80100fa8:	e8 bd 81 00 00       	call   8010916a <copyout>
80100fad:	85 c0                	test   %eax,%eax
80100faf:	79 05                	jns    80100fb6 <exec+0x376>
    goto bad;
80100fb1:	e9 99 00 00 00       	jmp    8010104f <exec+0x40f>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80100fb9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100fc2:	eb 13                	jmp    80100fd7 <exec+0x397>
    if(*s == '/')
80100fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fc7:	8a 00                	mov    (%eax),%al
80100fc9:	3c 2f                	cmp    $0x2f,%al
80100fcb:	75 07                	jne    80100fd4 <exec+0x394>
      last = s+1;
80100fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fd0:	40                   	inc    %eax
80100fd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fd4:	ff 45 f4             	incl   -0xc(%ebp)
80100fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fda:	8a 00                	mov    (%eax),%al
80100fdc:	84 c0                	test   %al,%al
80100fde:	75 e4                	jne    80100fc4 <exec+0x384>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fe0:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fe3:	8d 50 6c             	lea    0x6c(%eax),%edx
80100fe6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100fed:	00 
80100fee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ff5:	89 14 24             	mov    %edx,(%esp)
80100ff8:	e8 e5 4a 00 00       	call   80105ae2 <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100ffd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101000:	8b 40 04             	mov    0x4(%eax),%eax
80101003:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80101006:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101009:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010100c:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
8010100f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101012:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101015:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80101017:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010101a:	8b 40 18             	mov    0x18(%eax),%eax
8010101d:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80101023:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80101026:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101029:	8b 40 18             	mov    0x18(%eax),%eax
8010102c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010102f:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80101032:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101035:	89 04 24             	mov    %eax,(%esp)
80101038:	e8 13 7a 00 00       	call   80108a50 <switchuvm>
  freevm(oldpgdir);
8010103d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101040:	89 04 24             	mov    %eax,(%esp)
80101043:	e8 d4 7e 00 00       	call   80108f1c <freevm>
  return 0;
80101048:	b8 00 00 00 00       	mov    $0x0,%eax
8010104d:	eb 2c                	jmp    8010107b <exec+0x43b>

 bad:
  if(pgdir)
8010104f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101053:	74 0b                	je     80101060 <exec+0x420>
    freevm(pgdir);
80101055:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101058:	89 04 24             	mov    %eax,(%esp)
8010105b:	e8 bc 7e 00 00       	call   80108f1c <freevm>
  if(ip){
80101060:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80101064:	74 10                	je     80101076 <exec+0x436>
    iunlockput(ip);
80101066:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101069:	89 04 24             	mov    %eax,(%esp)
8010106c:	e8 b5 0c 00 00       	call   80101d26 <iunlockput>
    end_op();
80101071:	e8 d7 28 00 00       	call   8010394d <end_op>
  }
  return -1;
80101076:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010107b:	c9                   	leave  
8010107c:	c3                   	ret    
8010107d:	00 00                	add    %al,(%eax)
	...

80101080 <strcpy1>:
#include "file.h"
#include "container.h"



char* strcpy1(char *s, char *t){
80101080:	55                   	push   %ebp
80101081:	89 e5                	mov    %esp,%ebp
80101083:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80101086:	8b 45 08             	mov    0x8(%ebp),%eax
80101089:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
8010108c:	90                   	nop
8010108d:	8b 45 08             	mov    0x8(%ebp),%eax
80101090:	8d 50 01             	lea    0x1(%eax),%edx
80101093:	89 55 08             	mov    %edx,0x8(%ebp)
80101096:	8b 55 0c             	mov    0xc(%ebp),%edx
80101099:	8d 4a 01             	lea    0x1(%edx),%ecx
8010109c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010109f:	8a 12                	mov    (%edx),%dl
801010a1:	88 10                	mov    %dl,(%eax)
801010a3:	8a 00                	mov    (%eax),%al
801010a5:	84 c0                	test   %al,%al
801010a7:	75 e4                	jne    8010108d <strcpy1+0xd>
    ;
  return os;
801010a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801010ac:	c9                   	leave  
801010ad:	c3                   	ret    

801010ae <strcmp2>:

int
strcmp2(const char *p, const char *q){
801010ae:	55                   	push   %ebp
801010af:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
801010b1:	eb 06                	jmp    801010b9 <strcmp2+0xb>
    p++, q++;
801010b3:	ff 45 08             	incl   0x8(%ebp)
801010b6:	ff 45 0c             	incl   0xc(%ebp)
  return os;
}

int
strcmp2(const char *p, const char *q){
  while(*p && *p == *q)
801010b9:	8b 45 08             	mov    0x8(%ebp),%eax
801010bc:	8a 00                	mov    (%eax),%al
801010be:	84 c0                	test   %al,%al
801010c0:	74 0e                	je     801010d0 <strcmp2+0x22>
801010c2:	8b 45 08             	mov    0x8(%ebp),%eax
801010c5:	8a 10                	mov    (%eax),%dl
801010c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801010ca:	8a 00                	mov    (%eax),%al
801010cc:	38 c2                	cmp    %al,%dl
801010ce:	74 e3                	je     801010b3 <strcmp2+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801010d0:	8b 45 08             	mov    0x8(%ebp),%eax
801010d3:	8a 00                	mov    (%eax),%al
801010d5:	0f b6 d0             	movzbl %al,%edx
801010d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801010db:	8a 00                	mov    (%eax),%al
801010dd:	0f b6 c0             	movzbl %al,%eax
801010e0:	29 c2                	sub    %eax,%edx
801010e2:	89 d0                	mov    %edx,%eax
}
801010e4:	5d                   	pop    %ebp
801010e5:	c3                   	ret    

801010e6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010e6:	55                   	push   %ebp
801010e7:	89 e5                	mov    %esp,%ebp
801010e9:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801010ec:	c7 44 24 04 d1 9b 10 	movl   $0x80109bd1,0x4(%esp)
801010f3:	80 
801010f4:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801010fb:	e8 52 45 00 00       	call   80105652 <initlock>
}
80101100:	c9                   	leave  
80101101:	c3                   	ret    

80101102 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101102:	55                   	push   %ebp
80101103:	89 e5                	mov    %esp,%ebp
80101105:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
80101108:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010110f:	e8 5f 45 00 00       	call   80105673 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101114:	c7 45 f4 74 33 11 80 	movl   $0x80113374,-0xc(%ebp)
8010111b:	eb 29                	jmp    80101146 <filealloc+0x44>
    if(f->ref == 0){
8010111d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101120:	8b 40 04             	mov    0x4(%eax),%eax
80101123:	85 c0                	test   %eax,%eax
80101125:	75 1b                	jne    80101142 <filealloc+0x40>
      f->ref = 1;
80101127:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010112a:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101131:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80101138:	e8 a0 45 00 00       	call   801056dd <release>
      return f;
8010113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101140:	eb 1e                	jmp    80101160 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101142:	83 45 f4 1c          	addl   $0x1c,-0xc(%ebp)
80101146:	81 7d f4 64 3e 11 80 	cmpl   $0x80113e64,-0xc(%ebp)
8010114d:	72 ce                	jb     8010111d <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
8010114f:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
80101156:	e8 82 45 00 00       	call   801056dd <release>
  return 0;
8010115b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101160:	c9                   	leave  
80101161:	c3                   	ret    

80101162 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101162:	55                   	push   %ebp
80101163:	89 e5                	mov    %esp,%ebp
80101165:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101168:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010116f:	e8 ff 44 00 00       	call   80105673 <acquire>
  if(f->ref < 1)
80101174:	8b 45 08             	mov    0x8(%ebp),%eax
80101177:	8b 40 04             	mov    0x4(%eax),%eax
8010117a:	85 c0                	test   %eax,%eax
8010117c:	7f 0c                	jg     8010118a <filedup+0x28>
    panic("filedup");
8010117e:	c7 04 24 d8 9b 10 80 	movl   $0x80109bd8,(%esp)
80101185:	e8 ca f3 ff ff       	call   80100554 <panic>
  f->ref++;
8010118a:	8b 45 08             	mov    0x8(%ebp),%eax
8010118d:	8b 40 04             	mov    0x4(%eax),%eax
80101190:	8d 50 01             	lea    0x1(%eax),%edx
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101199:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011a0:	e8 38 45 00 00       	call   801056dd <release>
  return f;
801011a5:	8b 45 08             	mov    0x8(%ebp),%eax
}
801011a8:	c9                   	leave  
801011a9:	c3                   	ret    

801011aa <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801011aa:	55                   	push   %ebp
801011ab:	89 e5                	mov    %esp,%ebp
801011ad:	57                   	push   %edi
801011ae:	56                   	push   %esi
801011af:	53                   	push   %ebx
801011b0:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
801011b3:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011ba:	e8 b4 44 00 00       	call   80105673 <acquire>
  if(f->ref < 1)
801011bf:	8b 45 08             	mov    0x8(%ebp),%eax
801011c2:	8b 40 04             	mov    0x4(%eax),%eax
801011c5:	85 c0                	test   %eax,%eax
801011c7:	7f 0c                	jg     801011d5 <fileclose+0x2b>
    panic("fileclose");
801011c9:	c7 04 24 e0 9b 10 80 	movl   $0x80109be0,(%esp)
801011d0:	e8 7f f3 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
801011d5:	8b 45 08             	mov    0x8(%ebp),%eax
801011d8:	8b 40 04             	mov    0x4(%eax),%eax
801011db:	8d 50 ff             	lea    -0x1(%eax),%edx
801011de:	8b 45 08             	mov    0x8(%ebp),%eax
801011e1:	89 50 04             	mov    %edx,0x4(%eax)
801011e4:	8b 45 08             	mov    0x8(%ebp),%eax
801011e7:	8b 40 04             	mov    0x4(%eax),%eax
801011ea:	85 c0                	test   %eax,%eax
801011ec:	7e 0e                	jle    801011fc <fileclose+0x52>
    release(&ftable.lock);
801011ee:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
801011f5:	e8 e3 44 00 00       	call   801056dd <release>
801011fa:	eb 70                	jmp    8010126c <fileclose+0xc2>
    return;
  }
  ff = *f;
801011fc:	8b 45 08             	mov    0x8(%ebp),%eax
801011ff:	8d 55 cc             	lea    -0x34(%ebp),%edx
80101202:	89 c3                	mov    %eax,%ebx
80101204:	b8 07 00 00 00       	mov    $0x7,%eax
80101209:	89 d7                	mov    %edx,%edi
8010120b:	89 de                	mov    %ebx,%esi
8010120d:	89 c1                	mov    %eax,%ecx
8010120f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80101211:	8b 45 08             	mov    0x8(%ebp),%eax
80101214:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010121b:	8b 45 08             	mov    0x8(%ebp),%eax
8010121e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101224:	c7 04 24 40 33 11 80 	movl   $0x80113340,(%esp)
8010122b:	e8 ad 44 00 00       	call   801056dd <release>

  if(ff.type == FD_PIPE)
80101230:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101233:	83 f8 01             	cmp    $0x1,%eax
80101236:	75 17                	jne    8010124f <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
80101238:	8a 45 d5             	mov    -0x2b(%ebp),%al
8010123b:	0f be d0             	movsbl %al,%edx
8010123e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101241:	89 54 24 04          	mov    %edx,0x4(%esp)
80101245:	89 04 24             	mov    %eax,(%esp)
80101248:	e8 16 30 00 00       	call   80104263 <pipeclose>
8010124d:	eb 1d                	jmp    8010126c <fileclose+0xc2>
  else if(ff.type == FD_INODE){
8010124f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101252:	83 f8 02             	cmp    $0x2,%eax
80101255:	75 15                	jne    8010126c <fileclose+0xc2>
    begin_op();
80101257:	e8 6f 26 00 00       	call   801038cb <begin_op>
    iput(ff.ip);
8010125c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010125f:	89 04 24             	mov    %eax,(%esp)
80101262:	e8 0e 0a 00 00       	call   80101c75 <iput>
    end_op();
80101267:	e8 e1 26 00 00       	call   8010394d <end_op>
  }
}
8010126c:	83 c4 3c             	add    $0x3c,%esp
8010126f:	5b                   	pop    %ebx
80101270:	5e                   	pop    %esi
80101271:	5f                   	pop    %edi
80101272:	5d                   	pop    %ebp
80101273:	c3                   	ret    

80101274 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101274:	55                   	push   %ebp
80101275:	89 e5                	mov    %esp,%ebp
80101277:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
8010127a:	8b 45 08             	mov    0x8(%ebp),%eax
8010127d:	8b 00                	mov    (%eax),%eax
8010127f:	83 f8 02             	cmp    $0x2,%eax
80101282:	75 38                	jne    801012bc <filestat+0x48>
    ilock(f->ip);
80101284:	8b 45 08             	mov    0x8(%ebp),%eax
80101287:	8b 40 10             	mov    0x10(%eax),%eax
8010128a:	89 04 24             	mov    %eax,(%esp)
8010128d:	e8 95 08 00 00       	call   80101b27 <ilock>
    stati(f->ip, st);
80101292:	8b 45 08             	mov    0x8(%ebp),%eax
80101295:	8b 40 10             	mov    0x10(%eax),%eax
80101298:	8b 55 0c             	mov    0xc(%ebp),%edx
8010129b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010129f:	89 04 24             	mov    %eax,(%esp)
801012a2:	e8 d3 0c 00 00       	call   80101f7a <stati>
    iunlock(f->ip);
801012a7:	8b 45 08             	mov    0x8(%ebp),%eax
801012aa:	8b 40 10             	mov    0x10(%eax),%eax
801012ad:	89 04 24             	mov    %eax,(%esp)
801012b0:	e8 7c 09 00 00       	call   80101c31 <iunlock>
    return 0;
801012b5:	b8 00 00 00 00       	mov    $0x0,%eax
801012ba:	eb 05                	jmp    801012c1 <filestat+0x4d>
  }
  return -1;
801012bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801012c1:	c9                   	leave  
801012c2:	c3                   	ret    

801012c3 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801012c3:	55                   	push   %ebp
801012c4:	89 e5                	mov    %esp,%ebp
801012c6:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801012c9:	8b 45 08             	mov    0x8(%ebp),%eax
801012cc:	8a 40 08             	mov    0x8(%eax),%al
801012cf:	84 c0                	test   %al,%al
801012d1:	75 0a                	jne    801012dd <fileread+0x1a>
    return -1;
801012d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012d8:	e9 9f 00 00 00       	jmp    8010137c <fileread+0xb9>
  if(f->type == FD_PIPE)
801012dd:	8b 45 08             	mov    0x8(%ebp),%eax
801012e0:	8b 00                	mov    (%eax),%eax
801012e2:	83 f8 01             	cmp    $0x1,%eax
801012e5:	75 1e                	jne    80101305 <fileread+0x42>
    return piperead(f->pipe, addr, n);
801012e7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ea:	8b 40 0c             	mov    0xc(%eax),%eax
801012ed:	8b 55 10             	mov    0x10(%ebp),%edx
801012f0:	89 54 24 08          	mov    %edx,0x8(%esp)
801012f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801012f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801012fb:	89 04 24             	mov    %eax,(%esp)
801012fe:	e8 de 30 00 00       	call   801043e1 <piperead>
80101303:	eb 77                	jmp    8010137c <fileread+0xb9>
  if(f->type == FD_INODE){
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	8b 00                	mov    (%eax),%eax
8010130a:	83 f8 02             	cmp    $0x2,%eax
8010130d:	75 61                	jne    80101370 <fileread+0xad>
    ilock(f->ip);
8010130f:	8b 45 08             	mov    0x8(%ebp),%eax
80101312:	8b 40 10             	mov    0x10(%eax),%eax
80101315:	89 04 24             	mov    %eax,(%esp)
80101318:	e8 0a 08 00 00       	call   80101b27 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010131d:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101320:	8b 45 08             	mov    0x8(%ebp),%eax
80101323:	8b 50 14             	mov    0x14(%eax),%edx
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 40 10             	mov    0x10(%eax),%eax
8010132c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101330:	89 54 24 08          	mov    %edx,0x8(%esp)
80101334:	8b 55 0c             	mov    0xc(%ebp),%edx
80101337:	89 54 24 04          	mov    %edx,0x4(%esp)
8010133b:	89 04 24             	mov    %eax,(%esp)
8010133e:	e8 7b 0c 00 00       	call   80101fbe <readi>
80101343:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101346:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010134a:	7e 11                	jle    8010135d <fileread+0x9a>
      f->off += r;
8010134c:	8b 45 08             	mov    0x8(%ebp),%eax
8010134f:	8b 50 14             	mov    0x14(%eax),%edx
80101352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101355:	01 c2                	add    %eax,%edx
80101357:	8b 45 08             	mov    0x8(%ebp),%eax
8010135a:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010135d:	8b 45 08             	mov    0x8(%ebp),%eax
80101360:	8b 40 10             	mov    0x10(%eax),%eax
80101363:	89 04 24             	mov    %eax,(%esp)
80101366:	e8 c6 08 00 00       	call   80101c31 <iunlock>
    return r;
8010136b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010136e:	eb 0c                	jmp    8010137c <fileread+0xb9>
  }
  panic("fileread");
80101370:	c7 04 24 ea 9b 10 80 	movl   $0x80109bea,(%esp)
80101377:	e8 d8 f1 ff ff       	call   80100554 <panic>
}
8010137c:	c9                   	leave  
8010137d:	c3                   	ret    

8010137e <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010137e:	55                   	push   %ebp
8010137f:	89 e5                	mov    %esp,%ebp
80101381:	53                   	push   %ebx
80101382:	83 ec 24             	sub    $0x24,%esp
  //     x[i] = '\0';
  //     break;
  //   }
  // }

  if(f->writable == 0)
80101385:	8b 45 08             	mov    0x8(%ebp),%eax
80101388:	8a 40 09             	mov    0x9(%eax),%al
8010138b:	84 c0                	test   %al,%al
8010138d:	75 0a                	jne    80101399 <filewrite+0x1b>
    return -1;
8010138f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101394:	e9 20 01 00 00       	jmp    801014b9 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101399:	8b 45 08             	mov    0x8(%ebp),%eax
8010139c:	8b 00                	mov    (%eax),%eax
8010139e:	83 f8 01             	cmp    $0x1,%eax
801013a1:	75 21                	jne    801013c4 <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
801013a3:	8b 45 08             	mov    0x8(%ebp),%eax
801013a6:	8b 40 0c             	mov    0xc(%eax),%eax
801013a9:	8b 55 10             	mov    0x10(%ebp),%edx
801013ac:	89 54 24 08          	mov    %edx,0x8(%esp)
801013b0:	8b 55 0c             	mov    0xc(%ebp),%edx
801013b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801013b7:	89 04 24             	mov    %eax,(%esp)
801013ba:	e8 36 2f 00 00       	call   801042f5 <pipewrite>
801013bf:	e9 f5 00 00 00       	jmp    801014b9 <filewrite+0x13b>
  if(f->type == FD_INODE){
801013c4:	8b 45 08             	mov    0x8(%ebp),%eax
801013c7:	8b 00                	mov    (%eax),%eax
801013c9:	83 f8 02             	cmp    $0x2,%eax
801013cc:	0f 85 db 00 00 00    	jne    801014ad <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801013d2:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801013d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013e0:	e9 a8 00 00 00       	jmp    8010148d <filewrite+0x10f>
      int n1 = n - i;
801013e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013e8:	8b 55 10             	mov    0x10(%ebp),%edx
801013eb:	29 c2                	sub    %eax,%edx
801013ed:	89 d0                	mov    %edx,%eax
801013ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013f8:	7e 06                	jle    80101400 <filewrite+0x82>
        n1 = max;
801013fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013fd:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101400:	e8 c6 24 00 00       	call   801038cb <begin_op>
      ilock(f->ip);
80101405:	8b 45 08             	mov    0x8(%ebp),%eax
80101408:	8b 40 10             	mov    0x10(%eax),%eax
8010140b:	89 04 24             	mov    %eax,(%esp)
8010140e:	e8 14 07 00 00       	call   80101b27 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0){
80101413:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101416:	8b 45 08             	mov    0x8(%ebp),%eax
80101419:	8b 50 14             	mov    0x14(%eax),%edx
8010141c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010141f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101422:	01 c3                	add    %eax,%ebx
80101424:	8b 45 08             	mov    0x8(%ebp),%eax
80101427:	8b 40 10             	mov    0x10(%eax),%eax
8010142a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010142e:	89 54 24 08          	mov    %edx,0x8(%esp)
80101432:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101436:	89 04 24             	mov    %eax,(%esp)
80101439:	e8 e4 0c 00 00       	call   80102122 <writei>
8010143e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101441:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101445:	7e 11                	jle    80101458 <filewrite+0xda>
        f->off += r;
80101447:	8b 45 08             	mov    0x8(%ebp),%eax
8010144a:	8b 50 14             	mov    0x14(%eax),%edx
8010144d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101450:	01 c2                	add    %eax,%edx
80101452:	8b 45 08             	mov    0x8(%ebp),%eax
80101455:	89 50 14             	mov    %edx,0x14(%eax)
        // if(ticks > 0){
        //   struct superblock sb;
        //   readsb(1, &sb);
        // }
      }
      iunlock(f->ip);
80101458:	8b 45 08             	mov    0x8(%ebp),%eax
8010145b:	8b 40 10             	mov    0x10(%eax),%eax
8010145e:	89 04 24             	mov    %eax,(%esp)
80101461:	e8 cb 07 00 00       	call   80101c31 <iunlock>
      end_op();
80101466:	e8 e2 24 00 00       	call   8010394d <end_op>

      if(r < 0)
8010146b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010146f:	79 02                	jns    80101473 <filewrite+0xf5>
        break;
80101471:	eb 26                	jmp    80101499 <filewrite+0x11b>
      if(r != n1)
80101473:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101476:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101479:	74 0c                	je     80101487 <filewrite+0x109>
        panic("short filewrite");
8010147b:	c7 04 24 f3 9b 10 80 	movl   $0x80109bf3,(%esp)
80101482:	e8 cd f0 ff ff       	call   80100554 <panic>
      i += r;
80101487:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010148a:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
8010148d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101490:	3b 45 10             	cmp    0x10(%ebp),%eax
80101493:	0f 8c 4c ff ff ff    	jl     801013e5 <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010149c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010149f:	75 05                	jne    801014a6 <filewrite+0x128>
801014a1:	8b 45 10             	mov    0x10(%ebp),%eax
801014a4:	eb 05                	jmp    801014ab <filewrite+0x12d>
801014a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801014ab:	eb 0c                	jmp    801014b9 <filewrite+0x13b>
  }
  panic("filewrite");
801014ad:	c7 04 24 03 9c 10 80 	movl   $0x80109c03,(%esp)
801014b4:	e8 9b f0 ff ff       	call   80100554 <panic>
}
801014b9:	83 c4 24             	add    $0x24,%esp
801014bc:	5b                   	pop    %ebx
801014bd:	5d                   	pop    %ebp
801014be:	c3                   	ret    
	...

801014c0 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801014c0:	55                   	push   %ebp
801014c1:	89 e5                	mov    %esp,%ebp
801014c3:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014c6:	8b 45 08             	mov    0x8(%ebp),%eax
801014c9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801014d0:	00 
801014d1:	89 04 24             	mov    %eax,(%esp)
801014d4:	e8 dc ec ff ff       	call   801001b5 <bread>
801014d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014df:	83 c0 5c             	add    $0x5c,%eax
801014e2:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
801014e9:	00 
801014ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801014ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801014f1:	89 04 24             	mov    %eax,(%esp)
801014f4:	e8 a6 44 00 00       	call   8010599f <memmove>
  brelse(bp);
801014f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014fc:	89 04 24             	mov    %eax,(%esp)
801014ff:	e8 28 ed ff ff       	call   8010022c <brelse>
}
80101504:	c9                   	leave  
80101505:	c3                   	ret    

80101506 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
80101506:	55                   	push   %ebp
80101507:	89 e5                	mov    %esp,%ebp
80101509:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
8010150c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010150f:	8b 45 08             	mov    0x8(%ebp),%eax
80101512:	89 54 24 04          	mov    %edx,0x4(%esp)
80101516:	89 04 24             	mov    %eax,(%esp)
80101519:	e8 97 ec ff ff       	call   801001b5 <bread>
8010151e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101521:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101524:	83 c0 5c             	add    $0x5c,%eax
80101527:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010152e:	00 
8010152f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101536:	00 
80101537:	89 04 24             	mov    %eax,(%esp)
8010153a:	e8 97 43 00 00       	call   801058d6 <memset>
  log_write(bp);
8010153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101542:	89 04 24             	mov    %eax,(%esp)
80101545:	e8 85 25 00 00       	call   80103acf <log_write>
  brelse(bp);
8010154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154d:	89 04 24             	mov    %eax,(%esp)
80101550:	e8 d7 ec ff ff       	call   8010022c <brelse>
}
80101555:	c9                   	leave  
80101556:	c3                   	ret    

80101557 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101557:	55                   	push   %ebp
80101558:	89 e5                	mov    %esp,%ebp
8010155a:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010155d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101564:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010156b:	e9 03 01 00 00       	jmp    80101673 <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
80101570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101573:	85 c0                	test   %eax,%eax
80101575:	79 05                	jns    8010157c <balloc+0x25>
80101577:	05 ff 0f 00 00       	add    $0xfff,%eax
8010157c:	c1 f8 0c             	sar    $0xc,%eax
8010157f:	89 c2                	mov    %eax,%edx
80101581:	a1 f8 3e 11 80       	mov    0x80113ef8,%eax
80101586:	01 d0                	add    %edx,%eax
80101588:	89 44 24 04          	mov    %eax,0x4(%esp)
8010158c:	8b 45 08             	mov    0x8(%ebp),%eax
8010158f:	89 04 24             	mov    %eax,(%esp)
80101592:	e8 1e ec ff ff       	call   801001b5 <bread>
80101597:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010159a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801015a1:	e9 9b 00 00 00       	jmp    80101641 <balloc+0xea>
      m = 1 << (bi % 8);
801015a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a9:	25 07 00 00 80       	and    $0x80000007,%eax
801015ae:	85 c0                	test   %eax,%eax
801015b0:	79 05                	jns    801015b7 <balloc+0x60>
801015b2:	48                   	dec    %eax
801015b3:	83 c8 f8             	or     $0xfffffff8,%eax
801015b6:	40                   	inc    %eax
801015b7:	ba 01 00 00 00       	mov    $0x1,%edx
801015bc:	88 c1                	mov    %al,%cl
801015be:	d3 e2                	shl    %cl,%edx
801015c0:	89 d0                	mov    %edx,%eax
801015c2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c8:	85 c0                	test   %eax,%eax
801015ca:	79 03                	jns    801015cf <balloc+0x78>
801015cc:	83 c0 07             	add    $0x7,%eax
801015cf:	c1 f8 03             	sar    $0x3,%eax
801015d2:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015d5:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
801015d9:	0f b6 c0             	movzbl %al,%eax
801015dc:	23 45 e8             	and    -0x18(%ebp),%eax
801015df:	85 c0                	test   %eax,%eax
801015e1:	75 5b                	jne    8010163e <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e6:	85 c0                	test   %eax,%eax
801015e8:	79 03                	jns    801015ed <balloc+0x96>
801015ea:	83 c0 07             	add    $0x7,%eax
801015ed:	c1 f8 03             	sar    $0x3,%eax
801015f0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015f3:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
801015f7:	88 d1                	mov    %dl,%cl
801015f9:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015fc:	09 ca                	or     %ecx,%edx
801015fe:	88 d1                	mov    %dl,%cl
80101600:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101603:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
80101607:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010160a:	89 04 24             	mov    %eax,(%esp)
8010160d:	e8 bd 24 00 00       	call   80103acf <log_write>
        brelse(bp);
80101612:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101615:	89 04 24             	mov    %eax,(%esp)
80101618:	e8 0f ec ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
8010161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101620:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101623:	01 c2                	add    %eax,%edx
80101625:	8b 45 08             	mov    0x8(%ebp),%eax
80101628:	89 54 24 04          	mov    %edx,0x4(%esp)
8010162c:	89 04 24             	mov    %eax,(%esp)
8010162f:	e8 d2 fe ff ff       	call   80101506 <bzero>
        return b + bi;
80101634:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163a:	01 d0                	add    %edx,%eax
8010163c:	eb 51                	jmp    8010168f <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010163e:	ff 45 f0             	incl   -0x10(%ebp)
80101641:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101648:	7f 17                	jg     80101661 <balloc+0x10a>
8010164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010164d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101650:	01 d0                	add    %edx,%eax
80101652:	89 c2                	mov    %eax,%edx
80101654:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
80101659:	39 c2                	cmp    %eax,%edx
8010165b:	0f 82 45 ff ff ff    	jb     801015a6 <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101661:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101664:	89 04 24             	mov    %eax,(%esp)
80101667:	e8 c0 eb ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
8010166c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101673:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101676:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
8010167b:	39 c2                	cmp    %eax,%edx
8010167d:	0f 82 ed fe ff ff    	jb     80101570 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101683:	c7 04 24 10 9c 10 80 	movl   $0x80109c10,(%esp)
8010168a:	e8 c5 ee ff ff       	call   80100554 <panic>
}
8010168f:	c9                   	leave  
80101690:	c3                   	ret    

80101691 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101691:	55                   	push   %ebp
80101692:	89 e5                	mov    %esp,%ebp
80101694:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101697:	c7 44 24 04 e0 3e 11 	movl   $0x80113ee0,0x4(%esp)
8010169e:	80 
8010169f:	8b 45 08             	mov    0x8(%ebp),%eax
801016a2:	89 04 24             	mov    %eax,(%esp)
801016a5:	e8 16 fe ff ff       	call   801014c0 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
801016aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ad:	c1 e8 0c             	shr    $0xc,%eax
801016b0:	89 c2                	mov    %eax,%edx
801016b2:	a1 f8 3e 11 80       	mov    0x80113ef8,%eax
801016b7:	01 c2                	add    %eax,%edx
801016b9:	8b 45 08             	mov    0x8(%ebp),%eax
801016bc:	89 54 24 04          	mov    %edx,0x4(%esp)
801016c0:	89 04 24             	mov    %eax,(%esp)
801016c3:	e8 ed ea ff ff       	call   801001b5 <bread>
801016c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801016ce:	25 ff 0f 00 00       	and    $0xfff,%eax
801016d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d9:	25 07 00 00 80       	and    $0x80000007,%eax
801016de:	85 c0                	test   %eax,%eax
801016e0:	79 05                	jns    801016e7 <bfree+0x56>
801016e2:	48                   	dec    %eax
801016e3:	83 c8 f8             	or     $0xfffffff8,%eax
801016e6:	40                   	inc    %eax
801016e7:	ba 01 00 00 00       	mov    $0x1,%edx
801016ec:	88 c1                	mov    %al,%cl
801016ee:	d3 e2                	shl    %cl,%edx
801016f0:	89 d0                	mov    %edx,%eax
801016f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016f8:	85 c0                	test   %eax,%eax
801016fa:	79 03                	jns    801016ff <bfree+0x6e>
801016fc:	83 c0 07             	add    $0x7,%eax
801016ff:	c1 f8 03             	sar    $0x3,%eax
80101702:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101705:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
80101709:	0f b6 c0             	movzbl %al,%eax
8010170c:	23 45 ec             	and    -0x14(%ebp),%eax
8010170f:	85 c0                	test   %eax,%eax
80101711:	75 0c                	jne    8010171f <bfree+0x8e>
    panic("freeing free block");
80101713:	c7 04 24 26 9c 10 80 	movl   $0x80109c26,(%esp)
8010171a:	e8 35 ee ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
8010171f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101722:	85 c0                	test   %eax,%eax
80101724:	79 03                	jns    80101729 <bfree+0x98>
80101726:	83 c0 07             	add    $0x7,%eax
80101729:	c1 f8 03             	sar    $0x3,%eax
8010172c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010172f:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
80101733:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101736:	f7 d1                	not    %ecx
80101738:	21 ca                	and    %ecx,%edx
8010173a:	88 d1                	mov    %dl,%cl
8010173c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010173f:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101743:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101746:	89 04 24             	mov    %eax,(%esp)
80101749:	e8 81 23 00 00       	call   80103acf <log_write>
  brelse(bp);
8010174e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101751:	89 04 24             	mov    %eax,(%esp)
80101754:	e8 d3 ea ff ff       	call   8010022c <brelse>
}
80101759:	c9                   	leave  
8010175a:	c3                   	ret    

8010175b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010175b:	55                   	push   %ebp
8010175c:	89 e5                	mov    %esp,%ebp
8010175e:	57                   	push   %edi
8010175f:	56                   	push   %esi
80101760:	53                   	push   %ebx
80101761:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
80101764:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
8010176b:	c7 44 24 04 39 9c 10 	movl   $0x80109c39,0x4(%esp)
80101772:	80 
80101773:	c7 04 24 20 3f 11 80 	movl   $0x80113f20,(%esp)
8010177a:	e8 d3 3e 00 00       	call   80105652 <initlock>
  for(i = 0; i < NINODE; i++) {
8010177f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101786:	eb 2b                	jmp    801017b3 <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
80101788:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010178b:	89 d0                	mov    %edx,%eax
8010178d:	c1 e0 03             	shl    $0x3,%eax
80101790:	01 d0                	add    %edx,%eax
80101792:	c1 e0 04             	shl    $0x4,%eax
80101795:	83 c0 30             	add    $0x30,%eax
80101798:	05 20 3f 11 80       	add    $0x80113f20,%eax
8010179d:	83 c0 10             	add    $0x10,%eax
801017a0:	c7 44 24 04 40 9c 10 	movl   $0x80109c40,0x4(%esp)
801017a7:	80 
801017a8:	89 04 24             	mov    %eax,(%esp)
801017ab:	e8 64 3d 00 00       	call   80105514 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
801017b0:	ff 45 e4             	incl   -0x1c(%ebp)
801017b3:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801017b7:	7e cf                	jle    80101788 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
801017b9:	c7 44 24 04 e0 3e 11 	movl   $0x80113ee0,0x4(%esp)
801017c0:	80 
801017c1:	8b 45 08             	mov    0x8(%ebp),%eax
801017c4:	89 04 24             	mov    %eax,(%esp)
801017c7:	e8 f4 fc ff ff       	call   801014c0 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017cc:	a1 f8 3e 11 80       	mov    0x80113ef8,%eax
801017d1:	8b 3d f4 3e 11 80    	mov    0x80113ef4,%edi
801017d7:	8b 35 f0 3e 11 80    	mov    0x80113ef0,%esi
801017dd:	8b 1d ec 3e 11 80    	mov    0x80113eec,%ebx
801017e3:	8b 0d e8 3e 11 80    	mov    0x80113ee8,%ecx
801017e9:	8b 15 e4 3e 11 80    	mov    0x80113ee4,%edx
801017ef:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801017f2:	8b 15 e0 3e 11 80    	mov    0x80113ee0,%edx
801017f8:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801017fc:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101800:	89 74 24 14          	mov    %esi,0x14(%esp)
80101804:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80101808:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010180c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010180f:	89 44 24 08          	mov    %eax,0x8(%esp)
80101813:	89 d0                	mov    %edx,%eax
80101815:	89 44 24 04          	mov    %eax,0x4(%esp)
80101819:	c7 04 24 48 9c 10 80 	movl   $0x80109c48,(%esp)
80101820:	e8 9c eb ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
  sb.size_avail = (sb.nblocks/2) * 1024;
80101825:	a1 e4 3e 11 80       	mov    0x80113ee4,%eax
8010182a:	d1 e8                	shr    %eax
8010182c:	c1 e0 0a             	shl    $0xa,%eax
8010182f:	a3 00 3f 11 80       	mov    %eax,0x80113f00
  sb.size_used = ((sb.size - sb.nblocks)/2) * 1024;
80101834:	8b 15 e0 3e 11 80    	mov    0x80113ee0,%edx
8010183a:	a1 e4 3e 11 80       	mov    0x80113ee4,%eax
8010183f:	29 c2                	sub    %eax,%edx
80101841:	89 d0                	mov    %edx,%eax
80101843:	d1 e8                	shr    %eax
80101845:	c1 e0 0a             	shl    $0xa,%eax
80101848:	a3 04 3f 11 80       	mov    %eax,0x80113f04

  cprintf("dev %d\n", dev);
8010184d:	8b 45 08             	mov    0x8(%ebp),%eax
80101850:	89 44 24 04          	mov    %eax,0x4(%esp)
80101854:	c7 04 24 9b 9c 10 80 	movl   $0x80109c9b,(%esp)
8010185b:	e8 61 eb ff ff       	call   801003c1 <cprintf>
  cprintf("avail %d\n", sb.size_avail);
80101860:	a1 00 3f 11 80       	mov    0x80113f00,%eax
80101865:	89 44 24 04          	mov    %eax,0x4(%esp)
80101869:	c7 04 24 a3 9c 10 80 	movl   $0x80109ca3,(%esp)
80101870:	e8 4c eb ff ff       	call   801003c1 <cprintf>
  cprintf("used %d\n", sb.size_used);
80101875:	a1 04 3f 11 80       	mov    0x80113f04,%eax
8010187a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010187e:	c7 04 24 ad 9c 10 80 	movl   $0x80109cad,(%esp)
80101885:	e8 37 eb ff ff       	call   801003c1 <cprintf>
}
8010188a:	83 c4 4c             	add    $0x4c,%esp
8010188d:	5b                   	pop    %ebx
8010188e:	5e                   	pop    %esi
8010188f:	5f                   	pop    %edi
80101890:	5d                   	pop    %ebp
80101891:	c3                   	ret    

80101892 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101892:	55                   	push   %ebp
80101893:	89 e5                	mov    %esp,%ebp
80101895:	83 ec 28             	sub    $0x28,%esp
80101898:	8b 45 0c             	mov    0xc(%ebp),%eax
8010189b:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010189f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801018a6:	e9 9b 00 00 00       	jmp    80101946 <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
801018ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ae:	c1 e8 03             	shr    $0x3,%eax
801018b1:	89 c2                	mov    %eax,%edx
801018b3:	a1 f4 3e 11 80       	mov    0x80113ef4,%eax
801018b8:	01 d0                	add    %edx,%eax
801018ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801018be:	8b 45 08             	mov    0x8(%ebp),%eax
801018c1:	89 04 24             	mov    %eax,(%esp)
801018c4:	e8 ec e8 ff ff       	call   801001b5 <bread>
801018c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801018cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018cf:	8d 50 5c             	lea    0x5c(%eax),%edx
801018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d5:	83 e0 07             	and    $0x7,%eax
801018d8:	c1 e0 06             	shl    $0x6,%eax
801018db:	01 d0                	add    %edx,%eax
801018dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801018e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018e3:	8b 00                	mov    (%eax),%eax
801018e5:	66 85 c0             	test   %ax,%ax
801018e8:	75 4e                	jne    80101938 <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
801018ea:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801018f1:	00 
801018f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801018f9:	00 
801018fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801018fd:	89 04 24             	mov    %eax,(%esp)
80101900:	e8 d1 3f 00 00       	call   801058d6 <memset>
      dip->type = type;
80101905:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101908:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010190b:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
8010190e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101911:	89 04 24             	mov    %eax,(%esp)
80101914:	e8 b6 21 00 00       	call   80103acf <log_write>
      brelse(bp);
80101919:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010191c:	89 04 24             	mov    %eax,(%esp)
8010191f:	e8 08 e9 ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	89 44 24 04          	mov    %eax,0x4(%esp)
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	89 04 24             	mov    %eax,(%esp)
80101931:	e8 ea 00 00 00       	call   80101a20 <iget>
80101936:	eb 2a                	jmp    80101962 <ialloc+0xd0>
    }
    brelse(bp);
80101938:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010193b:	89 04 24             	mov    %eax,(%esp)
8010193e:	e8 e9 e8 ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101943:	ff 45 f4             	incl   -0xc(%ebp)
80101946:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101949:	a1 e8 3e 11 80       	mov    0x80113ee8,%eax
8010194e:	39 c2                	cmp    %eax,%edx
80101950:	0f 82 55 ff ff ff    	jb     801018ab <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101956:	c7 04 24 b6 9c 10 80 	movl   $0x80109cb6,(%esp)
8010195d:	e8 f2 eb ff ff       	call   80100554 <panic>
}
80101962:	c9                   	leave  
80101963:	c3                   	ret    

80101964 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101964:	55                   	push   %ebp
80101965:	89 e5                	mov    %esp,%ebp
80101967:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010196a:	8b 45 08             	mov    0x8(%ebp),%eax
8010196d:	8b 40 04             	mov    0x4(%eax),%eax
80101970:	c1 e8 03             	shr    $0x3,%eax
80101973:	89 c2                	mov    %eax,%edx
80101975:	a1 f4 3e 11 80       	mov    0x80113ef4,%eax
8010197a:	01 c2                	add    %eax,%edx
8010197c:	8b 45 08             	mov    0x8(%ebp),%eax
8010197f:	8b 00                	mov    (%eax),%eax
80101981:	89 54 24 04          	mov    %edx,0x4(%esp)
80101985:	89 04 24             	mov    %eax,(%esp)
80101988:	e8 28 e8 ff ff       	call   801001b5 <bread>
8010198d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101993:	8d 50 5c             	lea    0x5c(%eax),%edx
80101996:	8b 45 08             	mov    0x8(%ebp),%eax
80101999:	8b 40 04             	mov    0x4(%eax),%eax
8010199c:	83 e0 07             	and    $0x7,%eax
8010199f:	c1 e0 06             	shl    $0x6,%eax
801019a2:	01 d0                	add    %edx,%eax
801019a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801019a7:	8b 45 08             	mov    0x8(%ebp),%eax
801019aa:	8b 40 50             	mov    0x50(%eax),%eax
801019ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019b0:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
801019b3:	8b 45 08             	mov    0x8(%ebp),%eax
801019b6:	66 8b 40 52          	mov    0x52(%eax),%ax
801019ba:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019bd:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
801019c1:	8b 45 08             	mov    0x8(%ebp),%eax
801019c4:	8b 40 54             	mov    0x54(%eax),%eax
801019c7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019ca:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	66 8b 40 56          	mov    0x56(%eax),%ax
801019d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801019d8:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
801019dc:	8b 45 08             	mov    0x8(%ebp),%eax
801019df:	8b 50 58             	mov    0x58(%eax),%edx
801019e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e5:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801019e8:	8b 45 08             	mov    0x8(%ebp),%eax
801019eb:	8d 50 5c             	lea    0x5c(%eax),%edx
801019ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f1:	83 c0 0c             	add    $0xc,%eax
801019f4:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801019fb:	00 
801019fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a00:	89 04 24             	mov    %eax,(%esp)
80101a03:	e8 97 3f 00 00       	call   8010599f <memmove>
  log_write(bp);
80101a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0b:	89 04 24             	mov    %eax,(%esp)
80101a0e:	e8 bc 20 00 00       	call   80103acf <log_write>
  brelse(bp);
80101a13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a16:	89 04 24             	mov    %eax,(%esp)
80101a19:	e8 0e e8 ff ff       	call   8010022c <brelse>
}
80101a1e:	c9                   	leave  
80101a1f:	c3                   	ret    

80101a20 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101a20:	55                   	push   %ebp
80101a21:	89 e5                	mov    %esp,%ebp
80101a23:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101a26:	c7 04 24 20 3f 11 80 	movl   $0x80113f20,(%esp)
80101a2d:	e8 41 3c 00 00       	call   80105673 <acquire>

  // Is the inode already cached?
  empty = 0;
80101a32:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a39:	c7 45 f4 54 3f 11 80 	movl   $0x80113f54,-0xc(%ebp)
80101a40:	eb 5c                	jmp    80101a9e <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a45:	8b 40 08             	mov    0x8(%eax),%eax
80101a48:	85 c0                	test   %eax,%eax
80101a4a:	7e 35                	jle    80101a81 <iget+0x61>
80101a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4f:	8b 00                	mov    (%eax),%eax
80101a51:	3b 45 08             	cmp    0x8(%ebp),%eax
80101a54:	75 2b                	jne    80101a81 <iget+0x61>
80101a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a59:	8b 40 04             	mov    0x4(%eax),%eax
80101a5c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101a5f:	75 20                	jne    80101a81 <iget+0x61>
      ip->ref++;
80101a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a64:	8b 40 08             	mov    0x8(%eax),%eax
80101a67:	8d 50 01             	lea    0x1(%eax),%edx
80101a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a6d:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101a70:	c7 04 24 20 3f 11 80 	movl   $0x80113f20,(%esp)
80101a77:	e8 61 3c 00 00       	call   801056dd <release>
      return ip;
80101a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a7f:	eb 72                	jmp    80101af3 <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101a81:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a85:	75 10                	jne    80101a97 <iget+0x77>
80101a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8a:	8b 40 08             	mov    0x8(%eax),%eax
80101a8d:	85 c0                	test   %eax,%eax
80101a8f:	75 06                	jne    80101a97 <iget+0x77>
      empty = ip;
80101a91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a94:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a97:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a9e:	81 7d f4 74 5b 11 80 	cmpl   $0x80115b74,-0xc(%ebp)
80101aa5:	72 9b                	jb     80101a42 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101aa7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101aab:	75 0c                	jne    80101ab9 <iget+0x99>
    panic("iget: no inodes");
80101aad:	c7 04 24 c8 9c 10 80 	movl   $0x80109cc8,(%esp)
80101ab4:	e8 9b ea ff ff       	call   80100554 <panic>

  ip = empty;
80101ab9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101abc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ac2:	8b 55 08             	mov    0x8(%ebp),%edx
80101ac5:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101aca:	8b 55 0c             	mov    0xc(%ebp),%edx
80101acd:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101ad3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101add:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101ae4:	c7 04 24 20 3f 11 80 	movl   $0x80113f20,(%esp)
80101aeb:	e8 ed 3b 00 00       	call   801056dd <release>

  return ip;
80101af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101af3:	c9                   	leave  
80101af4:	c3                   	ret    

80101af5 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101af5:	55                   	push   %ebp
80101af6:	89 e5                	mov    %esp,%ebp
80101af8:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101afb:	c7 04 24 20 3f 11 80 	movl   $0x80113f20,(%esp)
80101b02:	e8 6c 3b 00 00       	call   80105673 <acquire>
  ip->ref++;
80101b07:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0a:	8b 40 08             	mov    0x8(%eax),%eax
80101b0d:	8d 50 01             	lea    0x1(%eax),%edx
80101b10:	8b 45 08             	mov    0x8(%ebp),%eax
80101b13:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101b16:	c7 04 24 20 3f 11 80 	movl   $0x80113f20,(%esp)
80101b1d:	e8 bb 3b 00 00       	call   801056dd <release>
  return ip;
80101b22:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101b25:	c9                   	leave  
80101b26:	c3                   	ret    

80101b27 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101b27:	55                   	push   %ebp
80101b28:	89 e5                	mov    %esp,%ebp
80101b2a:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101b2d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b31:	74 0a                	je     80101b3d <ilock+0x16>
80101b33:	8b 45 08             	mov    0x8(%ebp),%eax
80101b36:	8b 40 08             	mov    0x8(%eax),%eax
80101b39:	85 c0                	test   %eax,%eax
80101b3b:	7f 0c                	jg     80101b49 <ilock+0x22>
    panic("ilock");
80101b3d:	c7 04 24 d8 9c 10 80 	movl   $0x80109cd8,(%esp)
80101b44:	e8 0b ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101b49:	8b 45 08             	mov    0x8(%ebp),%eax
80101b4c:	83 c0 0c             	add    $0xc,%eax
80101b4f:	89 04 24             	mov    %eax,(%esp)
80101b52:	e8 f7 39 00 00       	call   8010554e <acquiresleep>

  if(ip->valid == 0){
80101b57:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b5d:	85 c0                	test   %eax,%eax
80101b5f:	0f 85 ca 00 00 00    	jne    80101c2f <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	8b 40 04             	mov    0x4(%eax),%eax
80101b6b:	c1 e8 03             	shr    $0x3,%eax
80101b6e:	89 c2                	mov    %eax,%edx
80101b70:	a1 f4 3e 11 80       	mov    0x80113ef4,%eax
80101b75:	01 c2                	add    %eax,%edx
80101b77:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7a:	8b 00                	mov    (%eax),%eax
80101b7c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b80:	89 04 24             	mov    %eax,(%esp)
80101b83:	e8 2d e6 ff ff       	call   801001b5 <bread>
80101b88:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b8e:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 04             	mov    0x4(%eax),%eax
80101b97:	83 e0 07             	and    $0x7,%eax
80101b9a:	c1 e0 06             	shl    $0x6,%eax
80101b9d:	01 d0                	add    %edx,%eax
80101b9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ba5:	8b 00                	mov    (%eax),%eax
80101ba7:	8b 55 08             	mov    0x8(%ebp),%edx
80101baa:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bb1:	66 8b 40 02          	mov    0x2(%eax),%ax
80101bb5:	8b 55 08             	mov    0x8(%ebp),%edx
80101bb8:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101bbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bbf:	8b 40 04             	mov    0x4(%eax),%eax
80101bc2:	8b 55 08             	mov    0x8(%ebp),%edx
80101bc5:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101bc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bcc:	66 8b 40 06          	mov    0x6(%eax),%ax
80101bd0:	8b 55 08             	mov    0x8(%ebp),%edx
80101bd3:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101bda:	8b 50 08             	mov    0x8(%eax),%edx
80101bdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101be0:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101be3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101be6:	8d 50 0c             	lea    0xc(%eax),%edx
80101be9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bec:	83 c0 5c             	add    $0x5c,%eax
80101bef:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101bf6:	00 
80101bf7:	89 54 24 04          	mov    %edx,0x4(%esp)
80101bfb:	89 04 24             	mov    %eax,(%esp)
80101bfe:	e8 9c 3d 00 00       	call   8010599f <memmove>
    brelse(bp);
80101c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c06:	89 04 24             	mov    %eax,(%esp)
80101c09:	e8 1e e6 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101c0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c11:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101c18:	8b 45 08             	mov    0x8(%ebp),%eax
80101c1b:	8b 40 50             	mov    0x50(%eax),%eax
80101c1e:	66 85 c0             	test   %ax,%ax
80101c21:	75 0c                	jne    80101c2f <ilock+0x108>
      panic("ilock: no type");
80101c23:	c7 04 24 de 9c 10 80 	movl   $0x80109cde,(%esp)
80101c2a:	e8 25 e9 ff ff       	call   80100554 <panic>
  }
}
80101c2f:	c9                   	leave  
80101c30:	c3                   	ret    

80101c31 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101c31:	55                   	push   %ebp
80101c32:	89 e5                	mov    %esp,%ebp
80101c34:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101c37:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101c3b:	74 1c                	je     80101c59 <iunlock+0x28>
80101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c40:	83 c0 0c             	add    $0xc,%eax
80101c43:	89 04 24             	mov    %eax,(%esp)
80101c46:	e8 a0 39 00 00       	call   801055eb <holdingsleep>
80101c4b:	85 c0                	test   %eax,%eax
80101c4d:	74 0a                	je     80101c59 <iunlock+0x28>
80101c4f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c52:	8b 40 08             	mov    0x8(%eax),%eax
80101c55:	85 c0                	test   %eax,%eax
80101c57:	7f 0c                	jg     80101c65 <iunlock+0x34>
    panic("iunlock");
80101c59:	c7 04 24 ed 9c 10 80 	movl   $0x80109ced,(%esp)
80101c60:	e8 ef e8 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101c65:	8b 45 08             	mov    0x8(%ebp),%eax
80101c68:	83 c0 0c             	add    $0xc,%eax
80101c6b:	89 04 24             	mov    %eax,(%esp)
80101c6e:	e8 36 39 00 00       	call   801055a9 <releasesleep>
}
80101c73:	c9                   	leave  
80101c74:	c3                   	ret    

80101c75 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101c75:	55                   	push   %ebp
80101c76:	89 e5                	mov    %esp,%ebp
80101c78:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101c7b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7e:	83 c0 0c             	add    $0xc,%eax
80101c81:	89 04 24             	mov    %eax,(%esp)
80101c84:	e8 c5 38 00 00       	call   8010554e <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101c89:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8c:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c8f:	85 c0                	test   %eax,%eax
80101c91:	74 5c                	je     80101cef <iput+0x7a>
80101c93:	8b 45 08             	mov    0x8(%ebp),%eax
80101c96:	66 8b 40 56          	mov    0x56(%eax),%ax
80101c9a:	66 85 c0             	test   %ax,%ax
80101c9d:	75 50                	jne    80101cef <iput+0x7a>
    acquire(&icache.lock);
80101c9f:	c7 04 24 20 3f 11 80 	movl   $0x80113f20,(%esp)
80101ca6:	e8 c8 39 00 00       	call   80105673 <acquire>
    int r = ip->ref;
80101cab:	8b 45 08             	mov    0x8(%ebp),%eax
80101cae:	8b 40 08             	mov    0x8(%eax),%eax
80101cb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101cb4:	c7 04 24 20 3f 11 80 	movl   $0x80113f20,(%esp)
80101cbb:	e8 1d 3a 00 00       	call   801056dd <release>
    if(r == 1){
80101cc0:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101cc4:	75 29                	jne    80101cef <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc9:	89 04 24             	mov    %eax,(%esp)
80101ccc:	e8 86 01 00 00       	call   80101e57 <itrunc>
      ip->type = 0;
80101cd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd4:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101cda:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdd:	89 04 24             	mov    %eax,(%esp)
80101ce0:	e8 7f fc ff ff       	call   80101964 <iupdate>
      ip->valid = 0;
80101ce5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101cef:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf2:	83 c0 0c             	add    $0xc,%eax
80101cf5:	89 04 24             	mov    %eax,(%esp)
80101cf8:	e8 ac 38 00 00       	call   801055a9 <releasesleep>

  acquire(&icache.lock);
80101cfd:	c7 04 24 20 3f 11 80 	movl   $0x80113f20,(%esp)
80101d04:	e8 6a 39 00 00       	call   80105673 <acquire>
  ip->ref--;
80101d09:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0c:	8b 40 08             	mov    0x8(%eax),%eax
80101d0f:	8d 50 ff             	lea    -0x1(%eax),%edx
80101d12:	8b 45 08             	mov    0x8(%ebp),%eax
80101d15:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101d18:	c7 04 24 20 3f 11 80 	movl   $0x80113f20,(%esp)
80101d1f:	e8 b9 39 00 00       	call   801056dd <release>
}
80101d24:	c9                   	leave  
80101d25:	c3                   	ret    

80101d26 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101d26:	55                   	push   %ebp
80101d27:	89 e5                	mov    %esp,%ebp
80101d29:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101d2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2f:	89 04 24             	mov    %eax,(%esp)
80101d32:	e8 fa fe ff ff       	call   80101c31 <iunlock>
  iput(ip);
80101d37:	8b 45 08             	mov    0x8(%ebp),%eax
80101d3a:	89 04 24             	mov    %eax,(%esp)
80101d3d:	e8 33 ff ff ff       	call   80101c75 <iput>
}
80101d42:	c9                   	leave  
80101d43:	c3                   	ret    

80101d44 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101d44:	55                   	push   %ebp
80101d45:	89 e5                	mov    %esp,%ebp
80101d47:	53                   	push   %ebx
80101d48:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101d4b:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101d4f:	77 3e                	ja     80101d8f <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101d51:	8b 45 08             	mov    0x8(%ebp),%eax
80101d54:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d57:	83 c2 14             	add    $0x14,%edx
80101d5a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d5e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d61:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d65:	75 20                	jne    80101d87 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101d67:	8b 45 08             	mov    0x8(%ebp),%eax
80101d6a:	8b 00                	mov    (%eax),%eax
80101d6c:	89 04 24             	mov    %eax,(%esp)
80101d6f:	e8 e3 f7 ff ff       	call   80101557 <balloc>
80101d74:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 55 0c             	mov    0xc(%ebp),%edx
80101d7d:	8d 4a 14             	lea    0x14(%edx),%ecx
80101d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d83:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d8a:	e9 c2 00 00 00       	jmp    80101e51 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101d8f:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d93:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d97:	0f 87 a8 00 00 00    	ja     80101e45 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101da0:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101da9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101dad:	75 1c                	jne    80101dcb <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101daf:	8b 45 08             	mov    0x8(%ebp),%eax
80101db2:	8b 00                	mov    (%eax),%eax
80101db4:	89 04 24             	mov    %eax,(%esp)
80101db7:	e8 9b f7 ff ff       	call   80101557 <balloc>
80101dbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dc5:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dce:	8b 00                	mov    (%eax),%eax
80101dd0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dd7:	89 04 24             	mov    %eax,(%esp)
80101dda:	e8 d6 e3 ff ff       	call   801001b5 <bread>
80101ddf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101de5:	83 c0 5c             	add    $0x5c,%eax
80101de8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101deb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df8:	01 d0                	add    %edx,%eax
80101dfa:	8b 00                	mov    (%eax),%eax
80101dfc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101dff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101e03:	75 30                	jne    80101e35 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101e05:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e08:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e12:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101e15:	8b 45 08             	mov    0x8(%ebp),%eax
80101e18:	8b 00                	mov    (%eax),%eax
80101e1a:	89 04 24             	mov    %eax,(%esp)
80101e1d:	e8 35 f7 ff ff       	call   80101557 <balloc>
80101e22:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e28:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101e2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2d:	89 04 24             	mov    %eax,(%esp)
80101e30:	e8 9a 1c 00 00       	call   80103acf <log_write>
    }
    brelse(bp);
80101e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e38:	89 04 24             	mov    %eax,(%esp)
80101e3b:	e8 ec e3 ff ff       	call   8010022c <brelse>
    return addr;
80101e40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101e43:	eb 0c                	jmp    80101e51 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101e45:	c7 04 24 f5 9c 10 80 	movl   $0x80109cf5,(%esp)
80101e4c:	e8 03 e7 ff ff       	call   80100554 <panic>
}
80101e51:	83 c4 24             	add    $0x24,%esp
80101e54:	5b                   	pop    %ebx
80101e55:	5d                   	pop    %ebp
80101e56:	c3                   	ret    

80101e57 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101e57:	55                   	push   %ebp
80101e58:	89 e5                	mov    %esp,%ebp
80101e5a:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e5d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101e64:	eb 43                	jmp    80101ea9 <itrunc+0x52>
    if(ip->addrs[i]){
80101e66:	8b 45 08             	mov    0x8(%ebp),%eax
80101e69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e6c:	83 c2 14             	add    $0x14,%edx
80101e6f:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101e73:	85 c0                	test   %eax,%eax
80101e75:	74 2f                	je     80101ea6 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101e77:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e7d:	83 c2 14             	add    $0x14,%edx
80101e80:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101e84:	8b 45 08             	mov    0x8(%ebp),%eax
80101e87:	8b 00                	mov    (%eax),%eax
80101e89:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e8d:	89 04 24             	mov    %eax,(%esp)
80101e90:	e8 fc f7 ff ff       	call   80101691 <bfree>
      ip->addrs[i] = 0;
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e9b:	83 c2 14             	add    $0x14,%edx
80101e9e:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101ea5:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101ea6:	ff 45 f4             	incl   -0xc(%ebp)
80101ea9:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101ead:	7e b7                	jle    80101e66 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101eb8:	85 c0                	test   %eax,%eax
80101eba:	0f 84 a3 00 00 00    	je     80101f63 <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec3:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecc:	8b 00                	mov    (%eax),%eax
80101ece:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ed2:	89 04 24             	mov    %eax,(%esp)
80101ed5:	e8 db e2 ff ff       	call   801001b5 <bread>
80101eda:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ee0:	83 c0 5c             	add    $0x5c,%eax
80101ee3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ee6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101eed:	eb 3a                	jmp    80101f29 <itrunc+0xd2>
      if(a[j])
80101eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ef2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ef9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101efc:	01 d0                	add    %edx,%eax
80101efe:	8b 00                	mov    (%eax),%eax
80101f00:	85 c0                	test   %eax,%eax
80101f02:	74 22                	je     80101f26 <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101f04:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101f0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101f11:	01 d0                	add    %edx,%eax
80101f13:	8b 10                	mov    (%eax),%edx
80101f15:	8b 45 08             	mov    0x8(%ebp),%eax
80101f18:	8b 00                	mov    (%eax),%eax
80101f1a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f1e:	89 04 24             	mov    %eax,(%esp)
80101f21:	e8 6b f7 ff ff       	call   80101691 <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101f26:	ff 45 f0             	incl   -0x10(%ebp)
80101f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f2c:	83 f8 7f             	cmp    $0x7f,%eax
80101f2f:	76 be                	jbe    80101eef <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101f34:	89 04 24             	mov    %eax,(%esp)
80101f37:	e8 f0 e2 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3f:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 00                	mov    (%eax),%eax
80101f4a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f4e:	89 04 24             	mov    %eax,(%esp)
80101f51:	e8 3b f7 ff ff       	call   80101691 <bfree>
    ip->addrs[NDIRECT] = 0;
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101f60:	00 00 00 
  }

  ip->size = 0;
80101f63:	8b 45 08             	mov    0x8(%ebp),%eax
80101f66:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f70:	89 04 24             	mov    %eax,(%esp)
80101f73:	e8 ec f9 ff ff       	call   80101964 <iupdate>
}
80101f78:	c9                   	leave  
80101f79:	c3                   	ret    

80101f7a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101f7a:	55                   	push   %ebp
80101f7b:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	8b 00                	mov    (%eax),%eax
80101f82:	89 c2                	mov    %eax,%edx
80101f84:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f87:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8d:	8b 50 04             	mov    0x4(%eax),%edx
80101f90:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f93:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f96:	8b 45 08             	mov    0x8(%ebp),%eax
80101f99:	8b 40 50             	mov    0x50(%eax),%eax
80101f9c:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f9f:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101fa2:	8b 45 08             	mov    0x8(%ebp),%eax
80101fa5:	66 8b 40 56          	mov    0x56(%eax),%ax
80101fa9:	8b 55 0c             	mov    0xc(%ebp),%edx
80101fac:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101fb0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fb3:	8b 50 58             	mov    0x58(%eax),%edx
80101fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101fb9:	89 50 10             	mov    %edx,0x10(%eax)
}
80101fbc:	5d                   	pop    %ebp
80101fbd:	c3                   	ret    

80101fbe <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101fbe:	55                   	push   %ebp
80101fbf:	89 e5                	mov    %esp,%ebp
80101fc1:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101fc7:	8b 40 50             	mov    0x50(%eax),%eax
80101fca:	66 83 f8 03          	cmp    $0x3,%ax
80101fce:	75 60                	jne    80102030 <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd3:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fd7:	66 85 c0             	test   %ax,%ax
80101fda:	78 20                	js     80101ffc <readi+0x3e>
80101fdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101fdf:	66 8b 40 52          	mov    0x52(%eax),%ax
80101fe3:	66 83 f8 09          	cmp    $0x9,%ax
80101fe7:	7f 13                	jg     80101ffc <readi+0x3e>
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	66 8b 40 52          	mov    0x52(%eax),%ax
80101ff0:	98                   	cwtl   
80101ff1:	8b 04 c5 80 3e 11 80 	mov    -0x7feec180(,%eax,8),%eax
80101ff8:	85 c0                	test   %eax,%eax
80101ffa:	75 0a                	jne    80102006 <readi+0x48>
      return -1;
80101ffc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102001:	e9 1a 01 00 00       	jmp    80102120 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80102006:	8b 45 08             	mov    0x8(%ebp),%eax
80102009:	66 8b 40 52          	mov    0x52(%eax),%ax
8010200d:	98                   	cwtl   
8010200e:	8b 04 c5 80 3e 11 80 	mov    -0x7feec180(,%eax,8),%eax
80102015:	8b 55 14             	mov    0x14(%ebp),%edx
80102018:	89 54 24 08          	mov    %edx,0x8(%esp)
8010201c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010201f:	89 54 24 04          	mov    %edx,0x4(%esp)
80102023:	8b 55 08             	mov    0x8(%ebp),%edx
80102026:	89 14 24             	mov    %edx,(%esp)
80102029:	ff d0                	call   *%eax
8010202b:	e9 f0 00 00 00       	jmp    80102120 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80102030:	8b 45 08             	mov    0x8(%ebp),%eax
80102033:	8b 40 58             	mov    0x58(%eax),%eax
80102036:	3b 45 10             	cmp    0x10(%ebp),%eax
80102039:	72 0d                	jb     80102048 <readi+0x8a>
8010203b:	8b 45 14             	mov    0x14(%ebp),%eax
8010203e:	8b 55 10             	mov    0x10(%ebp),%edx
80102041:	01 d0                	add    %edx,%eax
80102043:	3b 45 10             	cmp    0x10(%ebp),%eax
80102046:	73 0a                	jae    80102052 <readi+0x94>
    return -1;
80102048:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010204d:	e9 ce 00 00 00       	jmp    80102120 <readi+0x162>
  if(off + n > ip->size)
80102052:	8b 45 14             	mov    0x14(%ebp),%eax
80102055:	8b 55 10             	mov    0x10(%ebp),%edx
80102058:	01 c2                	add    %eax,%edx
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	8b 40 58             	mov    0x58(%eax),%eax
80102060:	39 c2                	cmp    %eax,%edx
80102062:	76 0c                	jbe    80102070 <readi+0xb2>
    n = ip->size - off;
80102064:	8b 45 08             	mov    0x8(%ebp),%eax
80102067:	8b 40 58             	mov    0x58(%eax),%eax
8010206a:	2b 45 10             	sub    0x10(%ebp),%eax
8010206d:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102070:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102077:	e9 95 00 00 00       	jmp    80102111 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
8010207c:	8b 45 10             	mov    0x10(%ebp),%eax
8010207f:	c1 e8 09             	shr    $0x9,%eax
80102082:	89 44 24 04          	mov    %eax,0x4(%esp)
80102086:	8b 45 08             	mov    0x8(%ebp),%eax
80102089:	89 04 24             	mov    %eax,(%esp)
8010208c:	e8 b3 fc ff ff       	call   80101d44 <bmap>
80102091:	8b 55 08             	mov    0x8(%ebp),%edx
80102094:	8b 12                	mov    (%edx),%edx
80102096:	89 44 24 04          	mov    %eax,0x4(%esp)
8010209a:	89 14 24             	mov    %edx,(%esp)
8010209d:	e8 13 e1 ff ff       	call   801001b5 <bread>
801020a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020a5:	8b 45 10             	mov    0x10(%ebp),%eax
801020a8:	25 ff 01 00 00       	and    $0x1ff,%eax
801020ad:	89 c2                	mov    %eax,%edx
801020af:	b8 00 02 00 00       	mov    $0x200,%eax
801020b4:	29 d0                	sub    %edx,%eax
801020b6:	89 c1                	mov    %eax,%ecx
801020b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801020bb:	8b 55 14             	mov    0x14(%ebp),%edx
801020be:	29 c2                	sub    %eax,%edx
801020c0:	89 c8                	mov    %ecx,%eax
801020c2:	39 d0                	cmp    %edx,%eax
801020c4:	76 02                	jbe    801020c8 <readi+0x10a>
801020c6:	89 d0                	mov    %edx,%eax
801020c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
801020cb:	8b 45 10             	mov    0x10(%ebp),%eax
801020ce:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d3:	8d 50 50             	lea    0x50(%eax),%edx
801020d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020d9:	01 d0                	add    %edx,%eax
801020db:	8d 50 0c             	lea    0xc(%eax),%edx
801020de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801020e1:	89 44 24 08          	mov    %eax,0x8(%esp)
801020e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801020e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801020ec:	89 04 24             	mov    %eax,(%esp)
801020ef:	e8 ab 38 00 00       	call   8010599f <memmove>
    brelse(bp);
801020f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020f7:	89 04 24             	mov    %eax,(%esp)
801020fa:	e8 2d e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801020ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102102:	01 45 f4             	add    %eax,-0xc(%ebp)
80102105:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102108:	01 45 10             	add    %eax,0x10(%ebp)
8010210b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010210e:	01 45 0c             	add    %eax,0xc(%ebp)
80102111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102114:	3b 45 14             	cmp    0x14(%ebp),%eax
80102117:	0f 82 5f ff ff ff    	jb     8010207c <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010211d:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102120:	c9                   	leave  
80102121:	c3                   	ret    

80102122 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102122:	55                   	push   %ebp
80102123:	89 e5                	mov    %esp,%ebp
80102125:	83 ec 38             	sub    $0x38,%esp
  uint tot, m;
  struct buf *bp;
  struct container* cont = myproc()->cont;
80102128:	e8 9e 24 00 00       	call   801045cb <myproc>
8010212d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102133:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int x = find(cont->name); // should be in range of 0-MAX_CONTAINERS to be utilized
80102136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102139:	83 c0 18             	add    $0x18,%eax
8010213c:	89 04 24             	mov    %eax,(%esp)
8010213f:	e8 d3 72 00 00       	call   80109417 <find>
80102144:	89 45 ec             	mov    %eax,-0x14(%ebp)

  if(ip->type == T_DEV){
80102147:	8b 45 08             	mov    0x8(%ebp),%eax
8010214a:	8b 40 50             	mov    0x50(%eax),%eax
8010214d:	66 83 f8 03          	cmp    $0x3,%ax
80102151:	75 60                	jne    801021b3 <writei+0x91>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write){
80102153:	8b 45 08             	mov    0x8(%ebp),%eax
80102156:	66 8b 40 52          	mov    0x52(%eax),%ax
8010215a:	66 85 c0             	test   %ax,%ax
8010215d:	78 20                	js     8010217f <writei+0x5d>
8010215f:	8b 45 08             	mov    0x8(%ebp),%eax
80102162:	66 8b 40 52          	mov    0x52(%eax),%ax
80102166:	66 83 f8 09          	cmp    $0x9,%ax
8010216a:	7f 13                	jg     8010217f <writei+0x5d>
8010216c:	8b 45 08             	mov    0x8(%ebp),%eax
8010216f:	66 8b 40 52          	mov    0x52(%eax),%ax
80102173:	98                   	cwtl   
80102174:	8b 04 c5 84 3e 11 80 	mov    -0x7feec17c(,%eax,8),%eax
8010217b:	85 c0                	test   %eax,%eax
8010217d:	75 0a                	jne    80102189 <writei+0x67>
      return -1;
8010217f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102184:	e9 9a 01 00 00       	jmp    80102323 <writei+0x201>
    }
    return devsw[ip->major].write(ip, src, n);
80102189:	8b 45 08             	mov    0x8(%ebp),%eax
8010218c:	66 8b 40 52          	mov    0x52(%eax),%ax
80102190:	98                   	cwtl   
80102191:	8b 04 c5 84 3e 11 80 	mov    -0x7feec17c(,%eax,8),%eax
80102198:	8b 55 14             	mov    0x14(%ebp),%edx
8010219b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010219f:	8b 55 0c             	mov    0xc(%ebp),%edx
801021a2:	89 54 24 04          	mov    %edx,0x4(%esp)
801021a6:	8b 55 08             	mov    0x8(%ebp),%edx
801021a9:	89 14 24             	mov    %edx,(%esp)
801021ac:	ff d0                	call   *%eax
801021ae:	e9 70 01 00 00       	jmp    80102323 <writei+0x201>
  }


  if(off > ip->size || off + n < off){
801021b3:	8b 45 08             	mov    0x8(%ebp),%eax
801021b6:	8b 40 58             	mov    0x58(%eax),%eax
801021b9:	3b 45 10             	cmp    0x10(%ebp),%eax
801021bc:	72 0d                	jb     801021cb <writei+0xa9>
801021be:	8b 45 14             	mov    0x14(%ebp),%eax
801021c1:	8b 55 10             	mov    0x10(%ebp),%edx
801021c4:	01 d0                	add    %edx,%eax
801021c6:	3b 45 10             	cmp    0x10(%ebp),%eax
801021c9:	73 0a                	jae    801021d5 <writei+0xb3>
    return -1;
801021cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021d0:	e9 4e 01 00 00       	jmp    80102323 <writei+0x201>
  }
  if(off + n > MAXFILE*BSIZE){
801021d5:	8b 45 14             	mov    0x14(%ebp),%eax
801021d8:	8b 55 10             	mov    0x10(%ebp),%edx
801021db:	01 d0                	add    %edx,%eax
801021dd:	3d 00 18 01 00       	cmp    $0x11800,%eax
801021e2:	76 0a                	jbe    801021ee <writei+0xcc>
    return -1;
801021e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021e9:	e9 35 01 00 00       	jmp    80102323 <writei+0x201>
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021ee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f5:	e9 a0 00 00 00       	jmp    8010229a <writei+0x178>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801021fa:	8b 45 10             	mov    0x10(%ebp),%eax
801021fd:	c1 e8 09             	shr    $0x9,%eax
80102200:	89 44 24 04          	mov    %eax,0x4(%esp)
80102204:	8b 45 08             	mov    0x8(%ebp),%eax
80102207:	89 04 24             	mov    %eax,(%esp)
8010220a:	e8 35 fb ff ff       	call   80101d44 <bmap>
8010220f:	8b 55 08             	mov    0x8(%ebp),%edx
80102212:	8b 12                	mov    (%edx),%edx
80102214:	89 44 24 04          	mov    %eax,0x4(%esp)
80102218:	89 14 24             	mov    %edx,(%esp)
8010221b:	e8 95 df ff ff       	call   801001b5 <bread>
80102220:	89 45 e8             	mov    %eax,-0x18(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102223:	8b 45 10             	mov    0x10(%ebp),%eax
80102226:	25 ff 01 00 00       	and    $0x1ff,%eax
8010222b:	89 c2                	mov    %eax,%edx
8010222d:	b8 00 02 00 00       	mov    $0x200,%eax
80102232:	29 d0                	sub    %edx,%eax
80102234:	89 c1                	mov    %eax,%ecx
80102236:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102239:	8b 55 14             	mov    0x14(%ebp),%edx
8010223c:	29 c2                	sub    %eax,%edx
8010223e:	89 c8                	mov    %ecx,%eax
80102240:	39 d0                	cmp    %edx,%eax
80102242:	76 02                	jbe    80102246 <writei+0x124>
80102244:	89 d0                	mov    %edx,%eax
80102246:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102249:	8b 45 10             	mov    0x10(%ebp),%eax
8010224c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102251:	8d 50 50             	lea    0x50(%eax),%edx
80102254:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102257:	01 d0                	add    %edx,%eax
80102259:	8d 50 0c             	lea    0xc(%eax),%edx
8010225c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010225f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102263:	8b 45 0c             	mov    0xc(%ebp),%eax
80102266:	89 44 24 04          	mov    %eax,0x4(%esp)
8010226a:	89 14 24             	mov    %edx,(%esp)
8010226d:	e8 2d 37 00 00       	call   8010599f <memmove>
    log_write(bp);
80102272:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102275:	89 04 24             	mov    %eax,(%esp)
80102278:	e8 52 18 00 00       	call   80103acf <log_write>
    brelse(bp);
8010227d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102280:	89 04 24             	mov    %eax,(%esp)
80102283:	e8 a4 df ff ff       	call   8010022c <brelse>
  }
  if(off + n > MAXFILE*BSIZE){
    return -1;
  }

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010228b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010228e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102291:	01 45 10             	add    %eax,0x10(%ebp)
80102294:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102297:	01 45 0c             	add    %eax,0xc(%ebp)
8010229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010229d:	3b 45 14             	cmp    0x14(%ebp),%eax
801022a0:	0f 82 54 ff ff ff    	jb     801021fa <writei+0xd8>
  }


  // void set_curr_disk(int disk, int vc_num){

  if(x >= 0){
801022a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801022aa:	78 4f                	js     801022fb <writei+0x1d9>
    if(tot>0){
801022ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801022b0:	74 49                	je     801022fb <writei+0x1d9>
      int before = get_curr_disk(x);
801022b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022b5:	89 04 24             	mov    %eax,(%esp)
801022b8:	e8 32 73 00 00       	call   801095ef <get_curr_disk>
801022bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
      set_curr_disk(tot, x);
801022c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022c3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801022c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801022ca:	89 04 24             	mov    %eax,(%esp)
801022cd:	e8 da 74 00 00       	call   801097ac <set_curr_disk>
      int after = get_curr_disk(x);
801022d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801022d5:	89 04 24             	mov    %eax,(%esp)
801022d8:	e8 12 73 00 00       	call   801095ef <get_curr_disk>
801022dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
      if(before == after){
801022e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801022e3:	3b 45 dc             	cmp    -0x24(%ebp),%eax
801022e6:	75 13                	jne    801022fb <writei+0x1d9>
        cstop_container_helper(myproc()->cont);
801022e8:	e8 de 22 00 00       	call   801045cb <myproc>
801022ed:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801022f3:	89 04 24             	mov    %eax,(%esp)
801022f6:	e8 61 2f 00 00       	call   8010525c <cstop_container_helper>
      }
    }
  }
  if(n > 0 && off > ip->size){
801022fb:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801022ff:	74 1f                	je     80102320 <writei+0x1fe>
80102301:	8b 45 08             	mov    0x8(%ebp),%eax
80102304:	8b 40 58             	mov    0x58(%eax),%eax
80102307:	3b 45 10             	cmp    0x10(%ebp),%eax
8010230a:	73 14                	jae    80102320 <writei+0x1fe>
    ip->size = off;
8010230c:	8b 45 08             	mov    0x8(%ebp),%eax
8010230f:	8b 55 10             	mov    0x10(%ebp),%edx
80102312:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102315:	8b 45 08             	mov    0x8(%ebp),%eax
80102318:	89 04 24             	mov    %eax,(%esp)
8010231b:	e8 44 f6 ff ff       	call   80101964 <iupdate>
  }
  return n;
80102320:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102323:	c9                   	leave  
80102324:	c3                   	ret    

80102325 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102325:	55                   	push   %ebp
80102326:	89 e5                	mov    %esp,%ebp
80102328:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010232b:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102332:	00 
80102333:	8b 45 0c             	mov    0xc(%ebp),%eax
80102336:	89 44 24 04          	mov    %eax,0x4(%esp)
8010233a:	8b 45 08             	mov    0x8(%ebp),%eax
8010233d:	89 04 24             	mov    %eax,(%esp)
80102340:	e8 f9 36 00 00       	call   80105a3e <strncmp>
}
80102345:	c9                   	leave  
80102346:	c3                   	ret    

80102347 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80102347:	55                   	push   %ebp
80102348:	89 e5                	mov    %esp,%ebp
8010234a:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
8010234d:	8b 45 08             	mov    0x8(%ebp),%eax
80102350:	8b 40 50             	mov    0x50(%eax),%eax
80102353:	66 83 f8 01          	cmp    $0x1,%ax
80102357:	74 0c                	je     80102365 <dirlookup+0x1e>
    panic("dirlookup not DIR");
80102359:	c7 04 24 08 9d 10 80 	movl   $0x80109d08,(%esp)
80102360:	e8 ef e1 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102365:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010236c:	e9 86 00 00 00       	jmp    801023f7 <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102371:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102378:	00 
80102379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102380:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102383:	89 44 24 04          	mov    %eax,0x4(%esp)
80102387:	8b 45 08             	mov    0x8(%ebp),%eax
8010238a:	89 04 24             	mov    %eax,(%esp)
8010238d:	e8 2c fc ff ff       	call   80101fbe <readi>
80102392:	83 f8 10             	cmp    $0x10,%eax
80102395:	74 0c                	je     801023a3 <dirlookup+0x5c>
      panic("dirlookup read");
80102397:	c7 04 24 1a 9d 10 80 	movl   $0x80109d1a,(%esp)
8010239e:	e8 b1 e1 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801023a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801023a6:	66 85 c0             	test   %ax,%ax
801023a9:	75 02                	jne    801023ad <dirlookup+0x66>
      continue;
801023ab:	eb 46                	jmp    801023f3 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
801023ad:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023b0:	83 c0 02             	add    $0x2,%eax
801023b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801023b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ba:	89 04 24             	mov    %eax,(%esp)
801023bd:	e8 63 ff ff ff       	call   80102325 <namecmp>
801023c2:	85 c0                	test   %eax,%eax
801023c4:	75 2d                	jne    801023f3 <dirlookup+0xac>
      // entry matches path element
      if(poff)
801023c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801023ca:	74 08                	je     801023d4 <dirlookup+0x8d>
        *poff = off;
801023cc:	8b 45 10             	mov    0x10(%ebp),%eax
801023cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
801023d2:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801023d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801023d7:	0f b7 c0             	movzwl %ax,%eax
801023da:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801023dd:	8b 45 08             	mov    0x8(%ebp),%eax
801023e0:	8b 00                	mov    (%eax),%eax
801023e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e5:	89 54 24 04          	mov    %edx,0x4(%esp)
801023e9:	89 04 24             	mov    %eax,(%esp)
801023ec:	e8 2f f6 ff ff       	call   80101a20 <iget>
801023f1:	eb 18                	jmp    8010240b <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801023f3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	8b 40 58             	mov    0x58(%eax),%eax
801023fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102400:	0f 87 6b ff ff ff    	ja     80102371 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102406:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010240b:	c9                   	leave  
8010240c:	c3                   	ret    

8010240d <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010240d:	55                   	push   %ebp
8010240e:	89 e5                	mov    %esp,%ebp
80102410:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102413:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010241a:	00 
8010241b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010241e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102422:	8b 45 08             	mov    0x8(%ebp),%eax
80102425:	89 04 24             	mov    %eax,(%esp)
80102428:	e8 1a ff ff ff       	call   80102347 <dirlookup>
8010242d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102430:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102434:	74 15                	je     8010244b <dirlink+0x3e>
    iput(ip);
80102436:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102439:	89 04 24             	mov    %eax,(%esp)
8010243c:	e8 34 f8 ff ff       	call   80101c75 <iput>
    return -1;
80102441:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102446:	e9 b6 00 00 00       	jmp    80102501 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010244b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102452:	eb 45                	jmp    80102499 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102457:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010245e:	00 
8010245f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102463:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102466:	89 44 24 04          	mov    %eax,0x4(%esp)
8010246a:	8b 45 08             	mov    0x8(%ebp),%eax
8010246d:	89 04 24             	mov    %eax,(%esp)
80102470:	e8 49 fb ff ff       	call   80101fbe <readi>
80102475:	83 f8 10             	cmp    $0x10,%eax
80102478:	74 0c                	je     80102486 <dirlink+0x79>
      panic("dirlink read");
8010247a:	c7 04 24 29 9d 10 80 	movl   $0x80109d29,(%esp)
80102481:	e8 ce e0 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102486:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102489:	66 85 c0             	test   %ax,%ax
8010248c:	75 02                	jne    80102490 <dirlink+0x83>
      break;
8010248e:	eb 16                	jmp    801024a6 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102493:	83 c0 10             	add    $0x10,%eax
80102496:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102499:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010249c:	8b 45 08             	mov    0x8(%ebp),%eax
8010249f:	8b 40 58             	mov    0x58(%eax),%eax
801024a2:	39 c2                	cmp    %eax,%edx
801024a4:	72 ae                	jb     80102454 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801024a6:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801024ad:	00 
801024ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801024b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801024b5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024b8:	83 c0 02             	add    $0x2,%eax
801024bb:	89 04 24             	mov    %eax,(%esp)
801024be:	e8 c9 35 00 00       	call   80105a8c <strncpy>
  de.inum = inum;
801024c3:	8b 45 10             	mov    0x10(%ebp),%eax
801024c6:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801024ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024cd:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801024d4:	00 
801024d5:	89 44 24 08          	mov    %eax,0x8(%esp)
801024d9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801024dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801024e0:	8b 45 08             	mov    0x8(%ebp),%eax
801024e3:	89 04 24             	mov    %eax,(%esp)
801024e6:	e8 37 fc ff ff       	call   80102122 <writei>
801024eb:	83 f8 10             	cmp    $0x10,%eax
801024ee:	74 0c                	je     801024fc <dirlink+0xef>
    panic("dirlink");
801024f0:	c7 04 24 36 9d 10 80 	movl   $0x80109d36,(%esp)
801024f7:	e8 58 e0 ff ff       	call   80100554 <panic>

  return 0;
801024fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102501:	c9                   	leave  
80102502:	c3                   	ret    

80102503 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102503:	55                   	push   %ebp
80102504:	89 e5                	mov    %esp,%ebp
80102506:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102509:	eb 03                	jmp    8010250e <skipelem+0xb>
    path++;
8010250b:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010250e:	8b 45 08             	mov    0x8(%ebp),%eax
80102511:	8a 00                	mov    (%eax),%al
80102513:	3c 2f                	cmp    $0x2f,%al
80102515:	74 f4                	je     8010250b <skipelem+0x8>
    path++;
  if(*path == 0)
80102517:	8b 45 08             	mov    0x8(%ebp),%eax
8010251a:	8a 00                	mov    (%eax),%al
8010251c:	84 c0                	test   %al,%al
8010251e:	75 0a                	jne    8010252a <skipelem+0x27>
    return 0;
80102520:	b8 00 00 00 00       	mov    $0x0,%eax
80102525:	e9 81 00 00 00       	jmp    801025ab <skipelem+0xa8>
  s = path;
8010252a:	8b 45 08             	mov    0x8(%ebp),%eax
8010252d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102530:	eb 03                	jmp    80102535 <skipelem+0x32>
    path++;
80102532:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102535:	8b 45 08             	mov    0x8(%ebp),%eax
80102538:	8a 00                	mov    (%eax),%al
8010253a:	3c 2f                	cmp    $0x2f,%al
8010253c:	74 09                	je     80102547 <skipelem+0x44>
8010253e:	8b 45 08             	mov    0x8(%ebp),%eax
80102541:	8a 00                	mov    (%eax),%al
80102543:	84 c0                	test   %al,%al
80102545:	75 eb                	jne    80102532 <skipelem+0x2f>
    path++;
  len = path - s;
80102547:	8b 55 08             	mov    0x8(%ebp),%edx
8010254a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010254d:	29 c2                	sub    %eax,%edx
8010254f:	89 d0                	mov    %edx,%eax
80102551:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102554:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102558:	7e 1c                	jle    80102576 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
8010255a:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102561:	00 
80102562:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102565:	89 44 24 04          	mov    %eax,0x4(%esp)
80102569:	8b 45 0c             	mov    0xc(%ebp),%eax
8010256c:	89 04 24             	mov    %eax,(%esp)
8010256f:	e8 2b 34 00 00       	call   8010599f <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102574:	eb 29                	jmp    8010259f <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102576:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102579:	89 44 24 08          	mov    %eax,0x8(%esp)
8010257d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102580:	89 44 24 04          	mov    %eax,0x4(%esp)
80102584:	8b 45 0c             	mov    0xc(%ebp),%eax
80102587:	89 04 24             	mov    %eax,(%esp)
8010258a:	e8 10 34 00 00       	call   8010599f <memmove>
    name[len] = 0;
8010258f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102592:	8b 45 0c             	mov    0xc(%ebp),%eax
80102595:	01 d0                	add    %edx,%eax
80102597:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010259a:	eb 03                	jmp    8010259f <skipelem+0x9c>
    path++;
8010259c:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010259f:	8b 45 08             	mov    0x8(%ebp),%eax
801025a2:	8a 00                	mov    (%eax),%al
801025a4:	3c 2f                	cmp    $0x2f,%al
801025a6:	74 f4                	je     8010259c <skipelem+0x99>
    path++;
  return path;
801025a8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801025ab:	c9                   	leave  
801025ac:	c3                   	ret    

801025ad <strcmp3>:

int
strcmp3(const char *p, const char *q)
{
801025ad:	55                   	push   %ebp
801025ae:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
801025b0:	eb 06                	jmp    801025b8 <strcmp3+0xb>
    p++, q++;
801025b2:	ff 45 08             	incl   0x8(%ebp)
801025b5:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp3(const char *p, const char *q)
{
  while(*p && *p == *q)
801025b8:	8b 45 08             	mov    0x8(%ebp),%eax
801025bb:	8a 00                	mov    (%eax),%al
801025bd:	84 c0                	test   %al,%al
801025bf:	74 0e                	je     801025cf <strcmp3+0x22>
801025c1:	8b 45 08             	mov    0x8(%ebp),%eax
801025c4:	8a 10                	mov    (%eax),%dl
801025c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801025c9:	8a 00                	mov    (%eax),%al
801025cb:	38 c2                	cmp    %al,%dl
801025cd:	74 e3                	je     801025b2 <strcmp3+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
801025cf:	8b 45 08             	mov    0x8(%ebp),%eax
801025d2:	8a 00                	mov    (%eax),%al
801025d4:	0f b6 d0             	movzbl %al,%edx
801025d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801025da:	8a 00                	mov    (%eax),%al
801025dc:	0f b6 c0             	movzbl %al,%eax
801025df:	29 c2                	sub    %eax,%edx
801025e1:	89 d0                	mov    %edx,%eax
}
801025e3:	5d                   	pop    %ebp
801025e4:	c3                   	ret    

801025e5 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801025e5:	55                   	push   %ebp
801025e6:	89 e5                	mov    %esp,%ebp
801025e8:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
801025eb:	8b 45 08             	mov    0x8(%ebp),%eax
801025ee:	8a 00                	mov    (%eax),%al
801025f0:	3c 2f                	cmp    $0x2f,%al
801025f2:	75 19                	jne    8010260d <namex+0x28>
    ip = iget(ROOTDEV, ROOTINO);
801025f4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025fb:	00 
801025fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102603:	e8 18 f4 ff ff       	call   80101a20 <iget>
80102608:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010260b:	eb 13                	jmp    80102620 <namex+0x3b>
  else
    ip = idup(myproc()->cwd);
8010260d:	e8 b9 1f 00 00       	call   801045cb <myproc>
80102612:	8b 40 68             	mov    0x68(%eax),%eax
80102615:	89 04 24             	mov    %eax,(%esp)
80102618:	e8 d8 f4 ff ff       	call   80101af5 <idup>
8010261d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  struct proc* p = myproc();
80102620:	e8 a6 1f 00 00       	call   801045cb <myproc>
80102625:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct container* cont = NULL;
80102628:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(p != NULL){
8010262f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80102633:	74 0c                	je     80102641 <namex+0x5c>
    cont = p->cont;
80102635:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102638:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010263e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  }

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
80102641:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
80102648:	00 
80102649:	c7 44 24 04 3e 9d 10 	movl   $0x80109d3e,0x4(%esp)
80102650:	80 
80102651:	8b 45 08             	mov    0x8(%ebp),%eax
80102654:	89 04 24             	mov    %eax,(%esp)
80102657:	e8 e2 33 00 00       	call   80105a3e <strncmp>
8010265c:	85 c0                	test   %eax,%eax
8010265e:	75 21                	jne    80102681 <namex+0x9c>
80102660:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102664:	74 1b                	je     80102681 <namex+0x9c>
80102666:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102669:	8b 40 38             	mov    0x38(%eax),%eax
8010266c:	8b 50 04             	mov    0x4(%eax),%edx
8010266f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102672:	8b 40 04             	mov    0x4(%eax),%eax
80102675:	39 c2                	cmp    %eax,%edx
80102677:	75 08                	jne    80102681 <namex+0x9c>
    return ip;
80102679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010267c:	e9 45 01 00 00       	jmp    801027c6 <namex+0x1e1>
  }
  
  while((path = skipelem(path, name)) != 0){
80102681:	e9 06 01 00 00       	jmp    8010278c <namex+0x1a7>
    ilock(ip);
80102686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102689:	89 04 24             	mov    %eax,(%esp)
8010268c:	e8 96 f4 ff ff       	call   80101b27 <ilock>

    if(ip->type != T_DIR){
80102691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102694:	8b 40 50             	mov    0x50(%eax),%eax
80102697:	66 83 f8 01          	cmp    $0x1,%ax
8010269b:	74 15                	je     801026b2 <namex+0xcd>
      iunlockput(ip);
8010269d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a0:	89 04 24             	mov    %eax,(%esp)
801026a3:	e8 7e f6 ff ff       	call   80101d26 <iunlockput>
      return 0;
801026a8:	b8 00 00 00 00       	mov    $0x0,%eax
801026ad:	e9 14 01 00 00       	jmp    801027c6 <namex+0x1e1>
    }

    if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
801026b2:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
801026b9:	00 
801026ba:	c7 44 24 04 3e 9d 10 	movl   $0x80109d3e,0x4(%esp)
801026c1:	80 
801026c2:	8b 45 08             	mov    0x8(%ebp),%eax
801026c5:	89 04 24             	mov    %eax,(%esp)
801026c8:	e8 71 33 00 00       	call   80105a3e <strncmp>
801026cd:	85 c0                	test   %eax,%eax
801026cf:	75 2c                	jne    801026fd <namex+0x118>
801026d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801026d5:	74 26                	je     801026fd <namex+0x118>
801026d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801026da:	8b 40 38             	mov    0x38(%eax),%eax
801026dd:	8b 50 04             	mov    0x4(%eax),%edx
801026e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e3:	8b 40 04             	mov    0x4(%eax),%eax
801026e6:	39 c2                	cmp    %eax,%edx
801026e8:	75 13                	jne    801026fd <namex+0x118>
      iunlock(ip);
801026ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026ed:	89 04 24             	mov    %eax,(%esp)
801026f0:	e8 3c f5 ff ff       	call   80101c31 <iunlock>
      return ip;
801026f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026f8:	e9 c9 00 00 00       	jmp    801027c6 <namex+0x1e1>
    }

    if(cont != NULL && ip->inum == ROOTINO){
801026fd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102701:	74 21                	je     80102724 <namex+0x13f>
80102703:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102706:	8b 40 04             	mov    0x4(%eax),%eax
80102709:	83 f8 01             	cmp    $0x1,%eax
8010270c:	75 16                	jne    80102724 <namex+0x13f>
      iunlock(ip);
8010270e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102711:	89 04 24             	mov    %eax,(%esp)
80102714:	e8 18 f5 ff ff       	call   80101c31 <iunlock>
      return cont->root;
80102719:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010271c:	8b 40 38             	mov    0x38(%eax),%eax
8010271f:	e9 a2 00 00 00       	jmp    801027c6 <namex+0x1e1>
    }

    if(nameiparent && *path == '\0'){
80102724:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102728:	74 1c                	je     80102746 <namex+0x161>
8010272a:	8b 45 08             	mov    0x8(%ebp),%eax
8010272d:	8a 00                	mov    (%eax),%al
8010272f:	84 c0                	test   %al,%al
80102731:	75 13                	jne    80102746 <namex+0x161>
      // Stop one level early.
      iunlock(ip);
80102733:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102736:	89 04 24             	mov    %eax,(%esp)
80102739:	e8 f3 f4 ff ff       	call   80101c31 <iunlock>
      return ip;
8010273e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102741:	e9 80 00 00 00       	jmp    801027c6 <namex+0x1e1>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102746:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010274d:	00 
8010274e:	8b 45 10             	mov    0x10(%ebp),%eax
80102751:	89 44 24 04          	mov    %eax,0x4(%esp)
80102755:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102758:	89 04 24             	mov    %eax,(%esp)
8010275b:	e8 e7 fb ff ff       	call   80102347 <dirlookup>
80102760:	89 45 e8             	mov    %eax,-0x18(%ebp)
80102763:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80102767:	75 12                	jne    8010277b <namex+0x196>
      iunlockput(ip);
80102769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276c:	89 04 24             	mov    %eax,(%esp)
8010276f:	e8 b2 f5 ff ff       	call   80101d26 <iunlockput>
      return 0;
80102774:	b8 00 00 00 00       	mov    $0x0,%eax
80102779:	eb 4b                	jmp    801027c6 <namex+0x1e1>
    }
    iunlockput(ip);
8010277b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010277e:	89 04 24             	mov    %eax,(%esp)
80102781:	e8 a0 f5 ff ff       	call   80101d26 <iunlockput>

    ip = next;
80102786:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102789:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(strncmp(path, "..",2) == 0 && cont != NULL && cont->root->inum == ip->inum){
    return ip;
  }
  
  while((path = skipelem(path, name)) != 0){
8010278c:	8b 45 10             	mov    0x10(%ebp),%eax
8010278f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102793:	8b 45 08             	mov    0x8(%ebp),%eax
80102796:	89 04 24             	mov    %eax,(%esp)
80102799:	e8 65 fd ff ff       	call   80102503 <skipelem>
8010279e:	89 45 08             	mov    %eax,0x8(%ebp)
801027a1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027a5:	0f 85 db fe ff ff    	jne    80102686 <namex+0xa1>
    }
    iunlockput(ip);

    ip = next;
  }
  if(nameiparent){
801027ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801027af:	74 12                	je     801027c3 <namex+0x1de>
    iput(ip);
801027b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027b4:	89 04 24             	mov    %eax,(%esp)
801027b7:	e8 b9 f4 ff ff       	call   80101c75 <iput>
    return 0;
801027bc:	b8 00 00 00 00       	mov    $0x0,%eax
801027c1:	eb 03                	jmp    801027c6 <namex+0x1e1>
  }

  
  return ip;
801027c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027c6:	c9                   	leave  
801027c7:	c3                   	ret    

801027c8 <namei>:

struct inode*
namei(char *path)
{
801027c8:	55                   	push   %ebp
801027c9:	89 e5                	mov    %esp,%ebp
801027cb:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801027ce:	8d 45 ea             	lea    -0x16(%ebp),%eax
801027d1:	89 44 24 08          	mov    %eax,0x8(%esp)
801027d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801027dc:	00 
801027dd:	8b 45 08             	mov    0x8(%ebp),%eax
801027e0:	89 04 24             	mov    %eax,(%esp)
801027e3:	e8 fd fd ff ff       	call   801025e5 <namex>
}
801027e8:	c9                   	leave  
801027e9:	c3                   	ret    

801027ea <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801027ea:	55                   	push   %ebp
801027eb:	89 e5                	mov    %esp,%ebp
801027ed:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801027f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801027f3:	89 44 24 08          	mov    %eax,0x8(%esp)
801027f7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801027fe:	00 
801027ff:	8b 45 08             	mov    0x8(%ebp),%eax
80102802:	89 04 24             	mov    %eax,(%esp)
80102805:	e8 db fd ff ff       	call   801025e5 <namex>
}
8010280a:	c9                   	leave  
8010280b:	c3                   	ret    

8010280c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010280c:	55                   	push   %ebp
8010280d:	89 e5                	mov    %esp,%ebp
8010280f:	83 ec 14             	sub    $0x14,%esp
80102812:	8b 45 08             	mov    0x8(%ebp),%eax
80102815:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102819:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010281c:	89 c2                	mov    %eax,%edx
8010281e:	ec                   	in     (%dx),%al
8010281f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102822:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102825:	c9                   	leave  
80102826:	c3                   	ret    

80102827 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102827:	55                   	push   %ebp
80102828:	89 e5                	mov    %esp,%ebp
8010282a:	57                   	push   %edi
8010282b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010282c:	8b 55 08             	mov    0x8(%ebp),%edx
8010282f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102832:	8b 45 10             	mov    0x10(%ebp),%eax
80102835:	89 cb                	mov    %ecx,%ebx
80102837:	89 df                	mov    %ebx,%edi
80102839:	89 c1                	mov    %eax,%ecx
8010283b:	fc                   	cld    
8010283c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010283e:	89 c8                	mov    %ecx,%eax
80102840:	89 fb                	mov    %edi,%ebx
80102842:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102845:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102848:	5b                   	pop    %ebx
80102849:	5f                   	pop    %edi
8010284a:	5d                   	pop    %ebp
8010284b:	c3                   	ret    

8010284c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010284c:	55                   	push   %ebp
8010284d:	89 e5                	mov    %esp,%ebp
8010284f:	83 ec 08             	sub    $0x8,%esp
80102852:	8b 45 08             	mov    0x8(%ebp),%eax
80102855:	8b 55 0c             	mov    0xc(%ebp),%edx
80102858:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010285c:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010285f:	8a 45 f8             	mov    -0x8(%ebp),%al
80102862:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102865:	ee                   	out    %al,(%dx)
}
80102866:	c9                   	leave  
80102867:	c3                   	ret    

80102868 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102868:	55                   	push   %ebp
80102869:	89 e5                	mov    %esp,%ebp
8010286b:	56                   	push   %esi
8010286c:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010286d:	8b 55 08             	mov    0x8(%ebp),%edx
80102870:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102873:	8b 45 10             	mov    0x10(%ebp),%eax
80102876:	89 cb                	mov    %ecx,%ebx
80102878:	89 de                	mov    %ebx,%esi
8010287a:	89 c1                	mov    %eax,%ecx
8010287c:	fc                   	cld    
8010287d:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010287f:	89 c8                	mov    %ecx,%eax
80102881:	89 f3                	mov    %esi,%ebx
80102883:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102886:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102889:	5b                   	pop    %ebx
8010288a:	5e                   	pop    %esi
8010288b:	5d                   	pop    %ebp
8010288c:	c3                   	ret    

8010288d <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010288d:	55                   	push   %ebp
8010288e:	89 e5                	mov    %esp,%ebp
80102890:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102893:	90                   	nop
80102894:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010289b:	e8 6c ff ff ff       	call   8010280c <inb>
801028a0:	0f b6 c0             	movzbl %al,%eax
801028a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801028a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028a9:	25 c0 00 00 00       	and    $0xc0,%eax
801028ae:	83 f8 40             	cmp    $0x40,%eax
801028b1:	75 e1                	jne    80102894 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801028b3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028b7:	74 11                	je     801028ca <idewait+0x3d>
801028b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028bc:	83 e0 21             	and    $0x21,%eax
801028bf:	85 c0                	test   %eax,%eax
801028c1:	74 07                	je     801028ca <idewait+0x3d>
    return -1;
801028c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801028c8:	eb 05                	jmp    801028cf <idewait+0x42>
  return 0;
801028ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801028cf:	c9                   	leave  
801028d0:	c3                   	ret    

801028d1 <ideinit>:

void
ideinit(void)
{
801028d1:	55                   	push   %ebp
801028d2:	89 e5                	mov    %esp,%ebp
801028d4:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
801028d7:	c7 44 24 04 41 9d 10 	movl   $0x80109d41,0x4(%esp)
801028de:	80 
801028df:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
801028e6:	e8 67 2d 00 00       	call   80105652 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801028eb:	a1 60 62 11 80       	mov    0x80116260,%eax
801028f0:	48                   	dec    %eax
801028f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801028f5:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801028fc:	e8 66 04 00 00       	call   80102d67 <ioapicenable>
  idewait(0);
80102901:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102908:	e8 80 ff ff ff       	call   8010288d <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010290d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102914:	00 
80102915:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010291c:	e8 2b ff ff ff       	call   8010284c <outb>
  for(i=0; i<1000; i++){
80102921:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102928:	eb 1f                	jmp    80102949 <ideinit+0x78>
    if(inb(0x1f7) != 0){
8010292a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102931:	e8 d6 fe ff ff       	call   8010280c <inb>
80102936:	84 c0                	test   %al,%al
80102938:	74 0c                	je     80102946 <ideinit+0x75>
      havedisk1 = 1;
8010293a:	c7 05 18 d9 10 80 01 	movl   $0x1,0x8010d918
80102941:	00 00 00 
      break;
80102944:	eb 0c                	jmp    80102952 <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102946:	ff 45 f4             	incl   -0xc(%ebp)
80102949:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102950:	7e d8                	jle    8010292a <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102952:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102959:	00 
8010295a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102961:	e8 e6 fe ff ff       	call   8010284c <outb>
}
80102966:	c9                   	leave  
80102967:	c3                   	ret    

80102968 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102968:	55                   	push   %ebp
80102969:	89 e5                	mov    %esp,%ebp
8010296b:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
8010296e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102972:	75 0c                	jne    80102980 <idestart+0x18>
    panic("idestart");
80102974:	c7 04 24 45 9d 10 80 	movl   $0x80109d45,(%esp)
8010297b:	e8 d4 db ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102980:	8b 45 08             	mov    0x8(%ebp),%eax
80102983:	8b 40 08             	mov    0x8(%eax),%eax
80102986:	3d 1f 4e 00 00       	cmp    $0x4e1f,%eax
8010298b:	76 0c                	jbe    80102999 <idestart+0x31>
    panic("incorrect blockno");
8010298d:	c7 04 24 4e 9d 10 80 	movl   $0x80109d4e,(%esp)
80102994:	e8 bb db ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102999:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801029a0:	8b 45 08             	mov    0x8(%ebp),%eax
801029a3:	8b 50 08             	mov    0x8(%eax),%edx
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	0f af c2             	imul   %edx,%eax
801029ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801029af:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801029b3:	75 07                	jne    801029bc <idestart+0x54>
801029b5:	b8 20 00 00 00       	mov    $0x20,%eax
801029ba:	eb 05                	jmp    801029c1 <idestart+0x59>
801029bc:	b8 c4 00 00 00       	mov    $0xc4,%eax
801029c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801029c4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801029c8:	75 07                	jne    801029d1 <idestart+0x69>
801029ca:	b8 30 00 00 00       	mov    $0x30,%eax
801029cf:	eb 05                	jmp    801029d6 <idestart+0x6e>
801029d1:	b8 c5 00 00 00       	mov    $0xc5,%eax
801029d6:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801029d9:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801029dd:	7e 0c                	jle    801029eb <idestart+0x83>
801029df:	c7 04 24 45 9d 10 80 	movl   $0x80109d45,(%esp)
801029e6:	e8 69 db ff ff       	call   80100554 <panic>

  idewait(0);
801029eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801029f2:	e8 96 fe ff ff       	call   8010288d <idewait>
  outb(0x3f6, 0);  // generate interrupt
801029f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801029fe:	00 
801029ff:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102a06:	e8 41 fe ff ff       	call   8010284c <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0e:	0f b6 c0             	movzbl %al,%eax
80102a11:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a15:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102a1c:	e8 2b fe ff ff       	call   8010284c <outb>
  outb(0x1f3, sector & 0xff);
80102a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a24:	0f b6 c0             	movzbl %al,%eax
80102a27:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a2b:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102a32:	e8 15 fe ff ff       	call   8010284c <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102a37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a3a:	c1 f8 08             	sar    $0x8,%eax
80102a3d:	0f b6 c0             	movzbl %al,%eax
80102a40:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a44:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102a4b:	e8 fc fd ff ff       	call   8010284c <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a53:	c1 f8 10             	sar    $0x10,%eax
80102a56:	0f b6 c0             	movzbl %al,%eax
80102a59:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a5d:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102a64:	e8 e3 fd ff ff       	call   8010284c <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102a69:	8b 45 08             	mov    0x8(%ebp),%eax
80102a6c:	8b 40 04             	mov    0x4(%eax),%eax
80102a6f:	83 e0 01             	and    $0x1,%eax
80102a72:	c1 e0 04             	shl    $0x4,%eax
80102a75:	88 c2                	mov    %al,%dl
80102a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102a7a:	c1 f8 18             	sar    $0x18,%eax
80102a7d:	83 e0 0f             	and    $0xf,%eax
80102a80:	09 d0                	or     %edx,%eax
80102a82:	83 c8 e0             	or     $0xffffffe0,%eax
80102a85:	0f b6 c0             	movzbl %al,%eax
80102a88:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a8c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102a93:	e8 b4 fd ff ff       	call   8010284c <outb>
  if(b->flags & B_DIRTY){
80102a98:	8b 45 08             	mov    0x8(%ebp),%eax
80102a9b:	8b 00                	mov    (%eax),%eax
80102a9d:	83 e0 04             	and    $0x4,%eax
80102aa0:	85 c0                	test   %eax,%eax
80102aa2:	74 36                	je     80102ada <idestart+0x172>
    outb(0x1f7, write_cmd);
80102aa4:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102aa7:	0f b6 c0             	movzbl %al,%eax
80102aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
80102aae:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102ab5:	e8 92 fd ff ff       	call   8010284c <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102aba:	8b 45 08             	mov    0x8(%ebp),%eax
80102abd:	83 c0 5c             	add    $0x5c,%eax
80102ac0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102ac7:	00 
80102ac8:	89 44 24 04          	mov    %eax,0x4(%esp)
80102acc:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102ad3:	e8 90 fd ff ff       	call   80102868 <outsl>
80102ad8:	eb 16                	jmp    80102af0 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102ada:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102add:	0f b6 c0             	movzbl %al,%eax
80102ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ae4:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102aeb:	e8 5c fd ff ff       	call   8010284c <outb>
  }
}
80102af0:	c9                   	leave  
80102af1:	c3                   	ret    

80102af2 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102af2:	55                   	push   %ebp
80102af3:	89 e5                	mov    %esp,%ebp
80102af5:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102af8:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102aff:	e8 6f 2b 00 00       	call   80105673 <acquire>

  if((b = idequeue) == 0){
80102b04:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102b09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102b10:	75 11                	jne    80102b23 <ideintr+0x31>
    release(&idelock);
80102b12:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102b19:	e8 bf 2b 00 00       	call   801056dd <release>
    return;
80102b1e:	e9 90 00 00 00       	jmp    80102bb3 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b26:	8b 40 58             	mov    0x58(%eax),%eax
80102b29:	a3 14 d9 10 80       	mov    %eax,0x8010d914

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b31:	8b 00                	mov    (%eax),%eax
80102b33:	83 e0 04             	and    $0x4,%eax
80102b36:	85 c0                	test   %eax,%eax
80102b38:	75 2e                	jne    80102b68 <ideintr+0x76>
80102b3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102b41:	e8 47 fd ff ff       	call   8010288d <idewait>
80102b46:	85 c0                	test   %eax,%eax
80102b48:	78 1e                	js     80102b68 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b4d:	83 c0 5c             	add    $0x5c,%eax
80102b50:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102b57:	00 
80102b58:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b5c:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102b63:	e8 bf fc ff ff       	call   80102827 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b6b:	8b 00                	mov    (%eax),%eax
80102b6d:	83 c8 02             	or     $0x2,%eax
80102b70:	89 c2                	mov    %eax,%edx
80102b72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b75:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b7a:	8b 00                	mov    (%eax),%eax
80102b7c:	83 e0 fb             	and    $0xfffffffb,%eax
80102b7f:	89 c2                	mov    %eax,%edx
80102b81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b84:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b89:	89 04 24             	mov    %eax,(%esp)
80102b8c:	e8 69 24 00 00       	call   80104ffa <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102b91:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102b96:	85 c0                	test   %eax,%eax
80102b98:	74 0d                	je     80102ba7 <ideintr+0xb5>
    idestart(idequeue);
80102b9a:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102b9f:	89 04 24             	mov    %eax,(%esp)
80102ba2:	e8 c1 fd ff ff       	call   80102968 <idestart>

  release(&idelock);
80102ba7:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102bae:	e8 2a 2b 00 00       	call   801056dd <release>
}
80102bb3:	c9                   	leave  
80102bb4:	c3                   	ret    

80102bb5 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102bb5:	55                   	push   %ebp
80102bb6:	89 e5                	mov    %esp,%ebp
80102bb8:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102bbb:	8b 45 08             	mov    0x8(%ebp),%eax
80102bbe:	83 c0 0c             	add    $0xc,%eax
80102bc1:	89 04 24             	mov    %eax,(%esp)
80102bc4:	e8 22 2a 00 00       	call   801055eb <holdingsleep>
80102bc9:	85 c0                	test   %eax,%eax
80102bcb:	75 0c                	jne    80102bd9 <iderw+0x24>
    panic("iderw: buf not locked");
80102bcd:	c7 04 24 60 9d 10 80 	movl   $0x80109d60,(%esp)
80102bd4:	e8 7b d9 ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80102bdc:	8b 00                	mov    (%eax),%eax
80102bde:	83 e0 06             	and    $0x6,%eax
80102be1:	83 f8 02             	cmp    $0x2,%eax
80102be4:	75 0c                	jne    80102bf2 <iderw+0x3d>
    panic("iderw: nothing to do");
80102be6:	c7 04 24 76 9d 10 80 	movl   $0x80109d76,(%esp)
80102bed:	e8 62 d9 ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bf5:	8b 40 04             	mov    0x4(%eax),%eax
80102bf8:	85 c0                	test   %eax,%eax
80102bfa:	74 15                	je     80102c11 <iderw+0x5c>
80102bfc:	a1 18 d9 10 80       	mov    0x8010d918,%eax
80102c01:	85 c0                	test   %eax,%eax
80102c03:	75 0c                	jne    80102c11 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102c05:	c7 04 24 8b 9d 10 80 	movl   $0x80109d8b,(%esp)
80102c0c:	e8 43 d9 ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102c11:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102c18:	e8 56 2a 00 00       	call   80105673 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102c1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c20:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102c27:	c7 45 f4 14 d9 10 80 	movl   $0x8010d914,-0xc(%ebp)
80102c2e:	eb 0b                	jmp    80102c3b <iderw+0x86>
80102c30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c33:	8b 00                	mov    (%eax),%eax
80102c35:	83 c0 58             	add    $0x58,%eax
80102c38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3e:	8b 00                	mov    (%eax),%eax
80102c40:	85 c0                	test   %eax,%eax
80102c42:	75 ec                	jne    80102c30 <iderw+0x7b>
    ;
  *pp = b;
80102c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c47:	8b 55 08             	mov    0x8(%ebp),%edx
80102c4a:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102c4c:	a1 14 d9 10 80       	mov    0x8010d914,%eax
80102c51:	3b 45 08             	cmp    0x8(%ebp),%eax
80102c54:	75 0d                	jne    80102c63 <iderw+0xae>
    idestart(b);
80102c56:	8b 45 08             	mov    0x8(%ebp),%eax
80102c59:	89 04 24             	mov    %eax,(%esp)
80102c5c:	e8 07 fd ff ff       	call   80102968 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102c61:	eb 15                	jmp    80102c78 <iderw+0xc3>
80102c63:	eb 13                	jmp    80102c78 <iderw+0xc3>
    sleep(b, &idelock);
80102c65:	c7 44 24 04 e0 d8 10 	movl   $0x8010d8e0,0x4(%esp)
80102c6c:	80 
80102c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c70:	89 04 24             	mov    %eax,(%esp)
80102c73:	e8 ab 22 00 00       	call   80104f23 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102c78:	8b 45 08             	mov    0x8(%ebp),%eax
80102c7b:	8b 00                	mov    (%eax),%eax
80102c7d:	83 e0 06             	and    $0x6,%eax
80102c80:	83 f8 02             	cmp    $0x2,%eax
80102c83:	75 e0                	jne    80102c65 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102c85:	c7 04 24 e0 d8 10 80 	movl   $0x8010d8e0,(%esp)
80102c8c:	e8 4c 2a 00 00       	call   801056dd <release>
}
80102c91:	c9                   	leave  
80102c92:	c3                   	ret    
	...

80102c94 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102c94:	55                   	push   %ebp
80102c95:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c97:	a1 74 5b 11 80       	mov    0x80115b74,%eax
80102c9c:	8b 55 08             	mov    0x8(%ebp),%edx
80102c9f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102ca1:	a1 74 5b 11 80       	mov    0x80115b74,%eax
80102ca6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ca9:	5d                   	pop    %ebp
80102caa:	c3                   	ret    

80102cab <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102cab:	55                   	push   %ebp
80102cac:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102cae:	a1 74 5b 11 80       	mov    0x80115b74,%eax
80102cb3:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102cb8:	a1 74 5b 11 80       	mov    0x80115b74,%eax
80102cbd:	8b 55 0c             	mov    0xc(%ebp),%edx
80102cc0:	89 50 10             	mov    %edx,0x10(%eax)
}
80102cc3:	5d                   	pop    %ebp
80102cc4:	c3                   	ret    

80102cc5 <ioapicinit>:

void
ioapicinit(void)
{
80102cc5:	55                   	push   %ebp
80102cc6:	89 e5                	mov    %esp,%ebp
80102cc8:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102ccb:	c7 05 74 5b 11 80 00 	movl   $0xfec00000,0x80115b74
80102cd2:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102cd5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102cdc:	e8 b3 ff ff ff       	call   80102c94 <ioapicread>
80102ce1:	c1 e8 10             	shr    $0x10,%eax
80102ce4:	25 ff 00 00 00       	and    $0xff,%eax
80102ce9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102cec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102cf3:	e8 9c ff ff ff       	call   80102c94 <ioapicread>
80102cf8:	c1 e8 18             	shr    $0x18,%eax
80102cfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102cfe:	a0 c0 5c 11 80       	mov    0x80115cc0,%al
80102d03:	0f b6 c0             	movzbl %al,%eax
80102d06:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102d09:	74 0c                	je     80102d17 <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102d0b:	c7 04 24 ac 9d 10 80 	movl   $0x80109dac,(%esp)
80102d12:	e8 aa d6 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102d17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102d1e:	eb 3d                	jmp    80102d5d <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d23:	83 c0 20             	add    $0x20,%eax
80102d26:	0d 00 00 01 00       	or     $0x10000,%eax
80102d2b:	89 c2                	mov    %eax,%edx
80102d2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d30:	83 c0 08             	add    $0x8,%eax
80102d33:	01 c0                	add    %eax,%eax
80102d35:	89 54 24 04          	mov    %edx,0x4(%esp)
80102d39:	89 04 24             	mov    %eax,(%esp)
80102d3c:	e8 6a ff ff ff       	call   80102cab <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d44:	83 c0 08             	add    $0x8,%eax
80102d47:	01 c0                	add    %eax,%eax
80102d49:	40                   	inc    %eax
80102d4a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102d51:	00 
80102d52:	89 04 24             	mov    %eax,(%esp)
80102d55:	e8 51 ff ff ff       	call   80102cab <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102d5a:	ff 45 f4             	incl   -0xc(%ebp)
80102d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d60:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102d63:	7e bb                	jle    80102d20 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102d65:	c9                   	leave  
80102d66:	c3                   	ret    

80102d67 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102d67:	55                   	push   %ebp
80102d68:	89 e5                	mov    %esp,%ebp
80102d6a:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102d70:	83 c0 20             	add    $0x20,%eax
80102d73:	89 c2                	mov    %eax,%edx
80102d75:	8b 45 08             	mov    0x8(%ebp),%eax
80102d78:	83 c0 08             	add    $0x8,%eax
80102d7b:	01 c0                	add    %eax,%eax
80102d7d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102d81:	89 04 24             	mov    %eax,(%esp)
80102d84:	e8 22 ff ff ff       	call   80102cab <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102d89:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d8c:	c1 e0 18             	shl    $0x18,%eax
80102d8f:	8b 55 08             	mov    0x8(%ebp),%edx
80102d92:	83 c2 08             	add    $0x8,%edx
80102d95:	01 d2                	add    %edx,%edx
80102d97:	42                   	inc    %edx
80102d98:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d9c:	89 14 24             	mov    %edx,(%esp)
80102d9f:	e8 07 ff ff ff       	call   80102cab <ioapicwrite>
}
80102da4:	c9                   	leave  
80102da5:	c3                   	ret    
	...

80102da8 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102da8:	55                   	push   %ebp
80102da9:	89 e5                	mov    %esp,%ebp
80102dab:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102dae:	c7 44 24 04 de 9d 10 	movl   $0x80109dde,0x4(%esp)
80102db5:	80 
80102db6:	c7 04 24 80 5b 11 80 	movl   $0x80115b80,(%esp)
80102dbd:	e8 90 28 00 00       	call   80105652 <initlock>
  kmem.use_lock = 0;
80102dc2:	c7 05 b4 5b 11 80 00 	movl   $0x0,0x80115bb4
80102dc9:	00 00 00 
  freerange(vstart, vend);
80102dcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102dd6:	89 04 24             	mov    %eax,(%esp)
80102dd9:	e8 30 00 00 00       	call   80102e0e <freerange>
}
80102dde:	c9                   	leave  
80102ddf:	c3                   	ret    

80102de0 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102de0:	55                   	push   %ebp
80102de1:	89 e5                	mov    %esp,%ebp
80102de3:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102de6:	8b 45 0c             	mov    0xc(%ebp),%eax
80102de9:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ded:	8b 45 08             	mov    0x8(%ebp),%eax
80102df0:	89 04 24             	mov    %eax,(%esp)
80102df3:	e8 16 00 00 00       	call   80102e0e <freerange>
  kmem.use_lock = 1;
80102df8:	c7 05 b4 5b 11 80 01 	movl   $0x1,0x80115bb4
80102dff:	00 00 00 
  kmem.i = 0;
80102e02:	c7 05 bc 5b 11 80 00 	movl   $0x0,0x80115bbc
80102e09:	00 00 00 
}
80102e0c:	c9                   	leave  
80102e0d:	c3                   	ret    

80102e0e <freerange>:

void
freerange(void *vstart, void *vend)
{
80102e0e:	55                   	push   %ebp
80102e0f:	89 e5                	mov    %esp,%ebp
80102e11:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102e14:	8b 45 08             	mov    0x8(%ebp),%eax
80102e17:	05 ff 0f 00 00       	add    $0xfff,%eax
80102e1c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102e21:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102e24:	eb 12                	jmp    80102e38 <freerange+0x2a>
    kfree(p);
80102e26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e29:	89 04 24             	mov    %eax,(%esp)
80102e2c:	e8 16 00 00 00       	call   80102e47 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102e31:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e3b:	05 00 10 00 00       	add    $0x1000,%eax
80102e40:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102e43:	76 e1                	jbe    80102e26 <freerange+0x18>
    kfree(p);
}
80102e45:	c9                   	leave  
80102e46:	c3                   	ret    

80102e47 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102e47:	55                   	push   %ebp
80102e48:	89 e5                	mov    %esp,%ebp
80102e4a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;


  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80102e50:	25 ff 0f 00 00       	and    $0xfff,%eax
80102e55:	85 c0                	test   %eax,%eax
80102e57:	75 18                	jne    80102e71 <kfree+0x2a>
80102e59:	81 7d 08 10 8e 11 80 	cmpl   $0x80118e10,0x8(%ebp)
80102e60:	72 0f                	jb     80102e71 <kfree+0x2a>
80102e62:	8b 45 08             	mov    0x8(%ebp),%eax
80102e65:	05 00 00 00 80       	add    $0x80000000,%eax
80102e6a:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102e6f:	76 0c                	jbe    80102e7d <kfree+0x36>
    panic("kfree");
80102e71:	c7 04 24 e3 9d 10 80 	movl   $0x80109de3,(%esp)
80102e78:	e8 d7 d6 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102e7d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102e84:	00 
80102e85:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102e8c:	00 
80102e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102e90:	89 04 24             	mov    %eax,(%esp)
80102e93:	e8 3e 2a 00 00       	call   801058d6 <memset>

  if(kmem.use_lock){
80102e98:	a1 b4 5b 11 80       	mov    0x80115bb4,%eax
80102e9d:	85 c0                	test   %eax,%eax
80102e9f:	74 5a                	je     80102efb <kfree+0xb4>
    acquire(&kmem.lock);
80102ea1:	c7 04 24 80 5b 11 80 	movl   $0x80115b80,(%esp)
80102ea8:	e8 c6 27 00 00       	call   80105673 <acquire>
    if(ticks > 1){
80102ead:	a1 00 8d 11 80       	mov    0x80118d00,%eax
80102eb2:	83 f8 01             	cmp    $0x1,%eax
80102eb5:	76 44                	jbe    80102efb <kfree+0xb4>
      int x = find(myproc()->cont->name);
80102eb7:	e8 0f 17 00 00       	call   801045cb <myproc>
80102ebc:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102ec2:	83 c0 18             	add    $0x18,%eax
80102ec5:	89 04 24             	mov    %eax,(%esp)
80102ec8:	e8 4a 65 00 00       	call   80109417 <find>
80102ecd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(x >= 0){
80102ed0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ed4:	78 25                	js     80102efb <kfree+0xb4>
        reduce_curr_mem(1, x);
80102ed6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ed9:	89 44 24 04          	mov    %eax,0x4(%esp)
80102edd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102ee4:	e8 81 68 00 00       	call   8010976a <reduce_curr_mem>
        myproc()->usage--;
80102ee9:	e8 dd 16 00 00       	call   801045cb <myproc>
80102eee:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80102ef4:	4a                   	dec    %edx
80102ef5:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
      }
    }
  }
  r = (struct run*)v;
80102efb:	8b 45 08             	mov    0x8(%ebp),%eax
80102efe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  r->next = kmem.freelist;
80102f01:	8b 15 b8 5b 11 80    	mov    0x80115bb8,%edx
80102f07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f0a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102f0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f0f:	a3 b8 5b 11 80       	mov    %eax,0x80115bb8
  kmem.i--;
80102f14:	a1 bc 5b 11 80       	mov    0x80115bbc,%eax
80102f19:	48                   	dec    %eax
80102f1a:	a3 bc 5b 11 80       	mov    %eax,0x80115bbc
  if(kmem.use_lock)
80102f1f:	a1 b4 5b 11 80       	mov    0x80115bb4,%eax
80102f24:	85 c0                	test   %eax,%eax
80102f26:	74 0c                	je     80102f34 <kfree+0xed>
    release(&kmem.lock);
80102f28:	c7 04 24 80 5b 11 80 	movl   $0x80115b80,(%esp)
80102f2f:	e8 a9 27 00 00       	call   801056dd <release>
}
80102f34:	c9                   	leave  
80102f35:	c3                   	ret    

80102f36 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102f36:	55                   	push   %ebp
80102f37:	89 e5                	mov    %esp,%ebp
80102f39:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock){
80102f3c:	a1 b4 5b 11 80       	mov    0x80115bb4,%eax
80102f41:	85 c0                	test   %eax,%eax
80102f43:	74 0c                	je     80102f51 <kalloc+0x1b>
    acquire(&kmem.lock);
80102f45:	c7 04 24 80 5b 11 80 	movl   $0x80115b80,(%esp)
80102f4c:	e8 22 27 00 00       	call   80105673 <acquire>
  }
  r = kmem.freelist;
80102f51:	a1 b8 5b 11 80       	mov    0x80115bb8,%eax
80102f56:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102f59:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f5d:	74 0a                	je     80102f69 <kalloc+0x33>
    kmem.freelist = r->next;
80102f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102f62:	8b 00                	mov    (%eax),%eax
80102f64:	a3 b8 5b 11 80       	mov    %eax,0x80115bb8
  kmem.i++;
80102f69:	a1 bc 5b 11 80       	mov    0x80115bbc,%eax
80102f6e:	40                   	inc    %eax
80102f6f:	a3 bc 5b 11 80       	mov    %eax,0x80115bbc
  if((char*)r != 0){
80102f74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102f78:	0f 84 84 00 00 00    	je     80103002 <kalloc+0xcc>
    if(ticks > 0){
80102f7e:	a1 00 8d 11 80       	mov    0x80118d00,%eax
80102f83:	85 c0                	test   %eax,%eax
80102f85:	74 7b                	je     80103002 <kalloc+0xcc>
      int x = find(myproc()->cont->name);
80102f87:	e8 3f 16 00 00       	call   801045cb <myproc>
80102f8c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102f92:	83 c0 18             	add    $0x18,%eax
80102f95:	89 04 24             	mov    %eax,(%esp)
80102f98:	e8 7a 64 00 00       	call   80109417 <find>
80102f9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(x >= 0){
80102fa0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102fa4:	78 5c                	js     80103002 <kalloc+0xcc>
        myproc()->usage++;
80102fa6:	e8 20 16 00 00       	call   801045cb <myproc>
80102fab:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80102fb1:	42                   	inc    %edx
80102fb2:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
        int before = get_curr_mem(x);
80102fb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbb:	89 04 24             	mov    %eax,(%esp)
80102fbe:	e8 ec 65 00 00       	call   801095af <get_curr_mem>
80102fc3:	89 45 ec             	mov    %eax,-0x14(%ebp)
        set_curr_mem(1, x);
80102fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fc9:	89 44 24 04          	mov    %eax,0x4(%esp)
80102fcd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102fd4:	e8 fe 66 00 00       	call   801096d7 <set_curr_mem>
        int after = get_curr_mem(x);
80102fd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fdc:	89 04 24             	mov    %eax,(%esp)
80102fdf:	e8 cb 65 00 00       	call   801095af <get_curr_mem>
80102fe4:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(before == after){
80102fe7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fea:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80102fed:	75 13                	jne    80103002 <kalloc+0xcc>
          cstop_container_helper(myproc()->cont);
80102fef:	e8 d7 15 00 00       	call   801045cb <myproc>
80102ff4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102ffa:	89 04 24             	mov    %eax,(%esp)
80102ffd:	e8 5a 22 00 00       	call   8010525c <cstop_container_helper>
        }
      }
   }
  }
  if(kmem.use_lock)
80103002:	a1 b4 5b 11 80       	mov    0x80115bb4,%eax
80103007:	85 c0                	test   %eax,%eax
80103009:	74 0c                	je     80103017 <kalloc+0xe1>
    release(&kmem.lock);
8010300b:	c7 04 24 80 5b 11 80 	movl   $0x80115b80,(%esp)
80103012:	e8 c6 26 00 00       	call   801056dd <release>
  return (char*)r;
80103017:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010301a:	c9                   	leave  
8010301b:	c3                   	ret    

8010301c <mem_usage>:

int mem_usage(void){
8010301c:	55                   	push   %ebp
8010301d:	89 e5                	mov    %esp,%ebp
  return kmem.i;
8010301f:	a1 bc 5b 11 80       	mov    0x80115bbc,%eax
}
80103024:	5d                   	pop    %ebp
80103025:	c3                   	ret    

80103026 <mem_avail>:

int mem_avail(void){
80103026:	55                   	push   %ebp
80103027:	89 e5                	mov    %esp,%ebp
80103029:	83 ec 10             	sub    $0x10,%esp
  int freebytes = ((P2V(4*1024*1024) - (void*)end) + (P2V(PHYSTOP) - P2V(4*1024*1024)))/4096;
8010302c:	b8 10 8e 11 80       	mov    $0x80118e10,%eax
80103031:	ba 00 00 00 8e       	mov    $0x8e000000,%edx
80103036:	29 c2                	sub    %eax,%edx
80103038:	89 d0                	mov    %edx,%eax
8010303a:	85 c0                	test   %eax,%eax
8010303c:	79 05                	jns    80103043 <mem_avail+0x1d>
8010303e:	05 ff 0f 00 00       	add    $0xfff,%eax
80103043:	c1 f8 0c             	sar    $0xc,%eax
80103046:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return freebytes;
80103049:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010304c:	c9                   	leave  
8010304d:	c3                   	ret    
	...

80103050 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	83 ec 14             	sub    $0x14,%esp
80103056:	8b 45 08             	mov    0x8(%ebp),%eax
80103059:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010305d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103060:	89 c2                	mov    %eax,%edx
80103062:	ec                   	in     (%dx),%al
80103063:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103066:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103069:	c9                   	leave  
8010306a:	c3                   	ret    

8010306b <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010306b:	55                   	push   %ebp
8010306c:	89 e5                	mov    %esp,%ebp
8010306e:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80103071:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103078:	e8 d3 ff ff ff       	call   80103050 <inb>
8010307d:	0f b6 c0             	movzbl %al,%eax
80103080:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80103083:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103086:	83 e0 01             	and    $0x1,%eax
80103089:	85 c0                	test   %eax,%eax
8010308b:	75 0a                	jne    80103097 <kbdgetc+0x2c>
    return -1;
8010308d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103092:	e9 21 01 00 00       	jmp    801031b8 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80103097:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
8010309e:	e8 ad ff ff ff       	call   80103050 <inb>
801030a3:	0f b6 c0             	movzbl %al,%eax
801030a6:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
801030a9:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
801030b0:	75 17                	jne    801030c9 <kbdgetc+0x5e>
    shift |= E0ESC;
801030b2:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
801030b7:	83 c8 40             	or     $0x40,%eax
801030ba:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
    return 0;
801030bf:	b8 00 00 00 00       	mov    $0x0,%eax
801030c4:	e9 ef 00 00 00       	jmp    801031b8 <kbdgetc+0x14d>
  } else if(data & 0x80){
801030c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030cc:	25 80 00 00 00       	and    $0x80,%eax
801030d1:	85 c0                	test   %eax,%eax
801030d3:	74 44                	je     80103119 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
801030d5:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
801030da:	83 e0 40             	and    $0x40,%eax
801030dd:	85 c0                	test   %eax,%eax
801030df:	75 08                	jne    801030e9 <kbdgetc+0x7e>
801030e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030e4:	83 e0 7f             	and    $0x7f,%eax
801030e7:	eb 03                	jmp    801030ec <kbdgetc+0x81>
801030e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
801030ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
801030f2:	05 20 b0 10 80       	add    $0x8010b020,%eax
801030f7:	8a 00                	mov    (%eax),%al
801030f9:	83 c8 40             	or     $0x40,%eax
801030fc:	0f b6 c0             	movzbl %al,%eax
801030ff:	f7 d0                	not    %eax
80103101:	89 c2                	mov    %eax,%edx
80103103:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103108:	21 d0                	and    %edx,%eax
8010310a:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
    return 0;
8010310f:	b8 00 00 00 00       	mov    $0x0,%eax
80103114:	e9 9f 00 00 00       	jmp    801031b8 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80103119:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
8010311e:	83 e0 40             	and    $0x40,%eax
80103121:	85 c0                	test   %eax,%eax
80103123:	74 14                	je     80103139 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80103125:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
8010312c:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103131:	83 e0 bf             	and    $0xffffffbf,%eax
80103134:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  }

  shift |= shiftcode[data];
80103139:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010313c:	05 20 b0 10 80       	add    $0x8010b020,%eax
80103141:	8a 00                	mov    (%eax),%al
80103143:	0f b6 d0             	movzbl %al,%edx
80103146:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
8010314b:	09 d0                	or     %edx,%eax
8010314d:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  shift ^= togglecode[data];
80103152:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103155:	05 20 b1 10 80       	add    $0x8010b120,%eax
8010315a:	8a 00                	mov    (%eax),%al
8010315c:	0f b6 d0             	movzbl %al,%edx
8010315f:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103164:	31 d0                	xor    %edx,%eax
80103166:	a3 1c d9 10 80       	mov    %eax,0x8010d91c
  c = charcode[shift & (CTL | SHIFT)][data];
8010316b:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
80103170:	83 e0 03             	and    $0x3,%eax
80103173:	8b 14 85 20 b5 10 80 	mov    -0x7fef4ae0(,%eax,4),%edx
8010317a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010317d:	01 d0                	add    %edx,%eax
8010317f:	8a 00                	mov    (%eax),%al
80103181:	0f b6 c0             	movzbl %al,%eax
80103184:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80103187:	a1 1c d9 10 80       	mov    0x8010d91c,%eax
8010318c:	83 e0 08             	and    $0x8,%eax
8010318f:	85 c0                	test   %eax,%eax
80103191:	74 22                	je     801031b5 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80103193:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80103197:	76 0c                	jbe    801031a5 <kbdgetc+0x13a>
80103199:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010319d:	77 06                	ja     801031a5 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010319f:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
801031a3:	eb 10                	jmp    801031b5 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
801031a5:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
801031a9:	76 0a                	jbe    801031b5 <kbdgetc+0x14a>
801031ab:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
801031af:	77 04                	ja     801031b5 <kbdgetc+0x14a>
      c += 'a' - 'A';
801031b1:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
801031b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
801031b8:	c9                   	leave  
801031b9:	c3                   	ret    

801031ba <kbdintr>:

void
kbdintr(void)
{
801031ba:	55                   	push   %ebp
801031bb:	89 e5                	mov    %esp,%ebp
801031bd:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
801031c0:	c7 04 24 6b 30 10 80 	movl   $0x8010306b,(%esp)
801031c7:	e8 29 d6 ff ff       	call   801007f5 <consoleintr>
}
801031cc:	c9                   	leave  
801031cd:	c3                   	ret    
	...

801031d0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801031d0:	55                   	push   %ebp
801031d1:	89 e5                	mov    %esp,%ebp
801031d3:	83 ec 14             	sub    $0x14,%esp
801031d6:	8b 45 08             	mov    0x8(%ebp),%eax
801031d9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801031dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031e0:	89 c2                	mov    %eax,%edx
801031e2:	ec                   	in     (%dx),%al
801031e3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801031e6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801031e9:	c9                   	leave  
801031ea:	c3                   	ret    

801031eb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801031eb:	55                   	push   %ebp
801031ec:	89 e5                	mov    %esp,%ebp
801031ee:	83 ec 08             	sub    $0x8,%esp
801031f1:	8b 45 08             	mov    0x8(%ebp),%eax
801031f4:	8b 55 0c             	mov    0xc(%ebp),%edx
801031f7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801031fb:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801031fe:	8a 45 f8             	mov    -0x8(%ebp),%al
80103201:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103204:	ee                   	out    %al,(%dx)
}
80103205:	c9                   	leave  
80103206:	c3                   	ret    

80103207 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80103207:	55                   	push   %ebp
80103208:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010320a:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
8010320f:	8b 55 08             	mov    0x8(%ebp),%edx
80103212:	c1 e2 02             	shl    $0x2,%edx
80103215:	01 c2                	add    %eax,%edx
80103217:	8b 45 0c             	mov    0xc(%ebp),%eax
8010321a:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
8010321c:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
80103221:	83 c0 20             	add    $0x20,%eax
80103224:	8b 00                	mov    (%eax),%eax
}
80103226:	5d                   	pop    %ebp
80103227:	c3                   	ret    

80103228 <lapicinit>:

void
lapicinit(void)
{
80103228:	55                   	push   %ebp
80103229:	89 e5                	mov    %esp,%ebp
8010322b:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
8010322e:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
80103233:	85 c0                	test   %eax,%eax
80103235:	75 05                	jne    8010323c <lapicinit+0x14>
    return;
80103237:	e9 43 01 00 00       	jmp    8010337f <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010323c:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80103243:	00 
80103244:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
8010324b:	e8 b7 ff ff ff       	call   80103207 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103250:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80103257:	00 
80103258:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
8010325f:	e8 a3 ff ff ff       	call   80103207 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103264:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
8010326b:	00 
8010326c:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103273:	e8 8f ff ff ff       	call   80103207 <lapicw>
  lapicw(TICR, 10000000);
80103278:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
8010327f:	00 
80103280:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80103287:	e8 7b ff ff ff       	call   80103207 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010328c:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103293:	00 
80103294:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
8010329b:	e8 67 ff ff ff       	call   80103207 <lapicw>
  lapicw(LINT1, MASKED);
801032a0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801032a7:	00 
801032a8:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801032af:	e8 53 ff ff ff       	call   80103207 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801032b4:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
801032b9:	83 c0 30             	add    $0x30,%eax
801032bc:	8b 00                	mov    (%eax),%eax
801032be:	c1 e8 10             	shr    $0x10,%eax
801032c1:	0f b6 c0             	movzbl %al,%eax
801032c4:	83 f8 03             	cmp    $0x3,%eax
801032c7:	76 14                	jbe    801032dd <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
801032c9:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801032d0:	00 
801032d1:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801032d8:	e8 2a ff ff ff       	call   80103207 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801032dd:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801032e4:	00 
801032e5:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801032ec:	e8 16 ff ff ff       	call   80103207 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801032f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801032f8:	00 
801032f9:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103300:	e8 02 ff ff ff       	call   80103207 <lapicw>
  lapicw(ESR, 0);
80103305:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010330c:	00 
8010330d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103314:	e8 ee fe ff ff       	call   80103207 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103319:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103320:	00 
80103321:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103328:	e8 da fe ff ff       	call   80103207 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
8010332d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103334:	00 
80103335:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010333c:	e8 c6 fe ff ff       	call   80103207 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103341:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103348:	00 
80103349:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103350:	e8 b2 fe ff ff       	call   80103207 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103355:	90                   	nop
80103356:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
8010335b:	05 00 03 00 00       	add    $0x300,%eax
80103360:	8b 00                	mov    (%eax),%eax
80103362:	25 00 10 00 00       	and    $0x1000,%eax
80103367:	85 c0                	test   %eax,%eax
80103369:	75 eb                	jne    80103356 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010336b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103372:	00 
80103373:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010337a:	e8 88 fe ff ff       	call   80103207 <lapicw>
}
8010337f:	c9                   	leave  
80103380:	c3                   	ret    

80103381 <lapicid>:

int
lapicid(void)
{
80103381:	55                   	push   %ebp
80103382:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103384:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
80103389:	85 c0                	test   %eax,%eax
8010338b:	75 07                	jne    80103394 <lapicid+0x13>
    return 0;
8010338d:	b8 00 00 00 00       	mov    $0x0,%eax
80103392:	eb 0d                	jmp    801033a1 <lapicid+0x20>
  return lapic[ID] >> 24;
80103394:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
80103399:	83 c0 20             	add    $0x20,%eax
8010339c:	8b 00                	mov    (%eax),%eax
8010339e:	c1 e8 18             	shr    $0x18,%eax
}
801033a1:	5d                   	pop    %ebp
801033a2:	c3                   	ret    

801033a3 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801033a3:	55                   	push   %ebp
801033a4:	89 e5                	mov    %esp,%ebp
801033a6:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801033a9:	a1 c0 5b 11 80       	mov    0x80115bc0,%eax
801033ae:	85 c0                	test   %eax,%eax
801033b0:	74 14                	je     801033c6 <lapiceoi+0x23>
    lapicw(EOI, 0);
801033b2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801033b9:	00 
801033ba:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801033c1:	e8 41 fe ff ff       	call   80103207 <lapicw>
}
801033c6:	c9                   	leave  
801033c7:	c3                   	ret    

801033c8 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
801033c8:	55                   	push   %ebp
801033c9:	89 e5                	mov    %esp,%ebp
}
801033cb:	5d                   	pop    %ebp
801033cc:	c3                   	ret    

801033cd <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
801033cd:	55                   	push   %ebp
801033ce:	89 e5                	mov    %esp,%ebp
801033d0:	83 ec 1c             	sub    $0x1c,%esp
801033d3:	8b 45 08             	mov    0x8(%ebp),%eax
801033d6:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801033d9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801033e0:	00 
801033e1:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801033e8:	e8 fe fd ff ff       	call   801031eb <outb>
  outb(CMOS_PORT+1, 0x0A);
801033ed:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801033f4:	00 
801033f5:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801033fc:	e8 ea fd ff ff       	call   801031eb <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103401:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103408:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010340b:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103410:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103413:	8d 50 02             	lea    0x2(%eax),%edx
80103416:	8b 45 0c             	mov    0xc(%ebp),%eax
80103419:	c1 e8 04             	shr    $0x4,%eax
8010341c:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010341f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103423:	c1 e0 18             	shl    $0x18,%eax
80103426:	89 44 24 04          	mov    %eax,0x4(%esp)
8010342a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103431:	e8 d1 fd ff ff       	call   80103207 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103436:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
8010343d:	00 
8010343e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103445:	e8 bd fd ff ff       	call   80103207 <lapicw>
  microdelay(200);
8010344a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103451:	e8 72 ff ff ff       	call   801033c8 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103456:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
8010345d:	00 
8010345e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103465:	e8 9d fd ff ff       	call   80103207 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010346a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103471:	e8 52 ff ff ff       	call   801033c8 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103476:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010347d:	eb 3f                	jmp    801034be <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
8010347f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103483:	c1 e0 18             	shl    $0x18,%eax
80103486:	89 44 24 04          	mov    %eax,0x4(%esp)
8010348a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103491:	e8 71 fd ff ff       	call   80103207 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103496:	8b 45 0c             	mov    0xc(%ebp),%eax
80103499:	c1 e8 0c             	shr    $0xc,%eax
8010349c:	80 cc 06             	or     $0x6,%ah
8010349f:	89 44 24 04          	mov    %eax,0x4(%esp)
801034a3:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801034aa:	e8 58 fd ff ff       	call   80103207 <lapicw>
    microdelay(200);
801034af:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801034b6:	e8 0d ff ff ff       	call   801033c8 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801034bb:	ff 45 fc             	incl   -0x4(%ebp)
801034be:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801034c2:	7e bb                	jle    8010347f <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801034c4:	c9                   	leave  
801034c5:	c3                   	ret    

801034c6 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801034c6:	55                   	push   %ebp
801034c7:	89 e5                	mov    %esp,%ebp
801034c9:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
801034cc:	8b 45 08             	mov    0x8(%ebp),%eax
801034cf:	0f b6 c0             	movzbl %al,%eax
801034d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801034d6:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801034dd:	e8 09 fd ff ff       	call   801031eb <outb>
  microdelay(200);
801034e2:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801034e9:	e8 da fe ff ff       	call   801033c8 <microdelay>

  return inb(CMOS_RETURN);
801034ee:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801034f5:	e8 d6 fc ff ff       	call   801031d0 <inb>
801034fa:	0f b6 c0             	movzbl %al,%eax
}
801034fd:	c9                   	leave  
801034fe:	c3                   	ret    

801034ff <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801034ff:	55                   	push   %ebp
80103500:	89 e5                	mov    %esp,%ebp
80103502:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103505:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010350c:	e8 b5 ff ff ff       	call   801034c6 <cmos_read>
80103511:	8b 55 08             	mov    0x8(%ebp),%edx
80103514:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80103516:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010351d:	e8 a4 ff ff ff       	call   801034c6 <cmos_read>
80103522:	8b 55 08             	mov    0x8(%ebp),%edx
80103525:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103528:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010352f:	e8 92 ff ff ff       	call   801034c6 <cmos_read>
80103534:	8b 55 08             	mov    0x8(%ebp),%edx
80103537:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010353a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103541:	e8 80 ff ff ff       	call   801034c6 <cmos_read>
80103546:	8b 55 08             	mov    0x8(%ebp),%edx
80103549:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010354c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103553:	e8 6e ff ff ff       	call   801034c6 <cmos_read>
80103558:	8b 55 08             	mov    0x8(%ebp),%edx
8010355b:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010355e:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103565:	e8 5c ff ff ff       	call   801034c6 <cmos_read>
8010356a:	8b 55 08             	mov    0x8(%ebp),%edx
8010356d:	89 42 14             	mov    %eax,0x14(%edx)
}
80103570:	c9                   	leave  
80103571:	c3                   	ret    

80103572 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103572:	55                   	push   %ebp
80103573:	89 e5                	mov    %esp,%ebp
80103575:	57                   	push   %edi
80103576:	56                   	push   %esi
80103577:	53                   	push   %ebx
80103578:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010357b:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103582:	e8 3f ff ff ff       	call   801034c6 <cmos_read>
80103587:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010358a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010358d:	83 e0 04             	and    $0x4,%eax
80103590:	85 c0                	test   %eax,%eax
80103592:	0f 94 c0             	sete   %al
80103595:	0f b6 c0             	movzbl %al,%eax
80103598:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010359b:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010359e:	89 04 24             	mov    %eax,(%esp)
801035a1:	e8 59 ff ff ff       	call   801034ff <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801035a6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801035ad:	e8 14 ff ff ff       	call   801034c6 <cmos_read>
801035b2:	25 80 00 00 00       	and    $0x80,%eax
801035b7:	85 c0                	test   %eax,%eax
801035b9:	74 02                	je     801035bd <cmostime+0x4b>
        continue;
801035bb:	eb 36                	jmp    801035f3 <cmostime+0x81>
    fill_rtcdate(&t2);
801035bd:	8d 45 b0             	lea    -0x50(%ebp),%eax
801035c0:	89 04 24             	mov    %eax,(%esp)
801035c3:	e8 37 ff ff ff       	call   801034ff <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801035c8:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801035cf:	00 
801035d0:	8d 45 b0             	lea    -0x50(%ebp),%eax
801035d3:	89 44 24 04          	mov    %eax,0x4(%esp)
801035d7:	8d 45 c8             	lea    -0x38(%ebp),%eax
801035da:	89 04 24             	mov    %eax,(%esp)
801035dd:	e8 6b 23 00 00       	call   8010594d <memcmp>
801035e2:	85 c0                	test   %eax,%eax
801035e4:	75 0d                	jne    801035f3 <cmostime+0x81>
      break;
801035e6:	90                   	nop
  }

  // convert
  if(bcd) {
801035e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801035eb:	0f 84 ac 00 00 00    	je     8010369d <cmostime+0x12b>
801035f1:	eb 02                	jmp    801035f5 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801035f3:	eb a6                	jmp    8010359b <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801035f5:	8b 45 c8             	mov    -0x38(%ebp),%eax
801035f8:	c1 e8 04             	shr    $0x4,%eax
801035fb:	89 c2                	mov    %eax,%edx
801035fd:	89 d0                	mov    %edx,%eax
801035ff:	c1 e0 02             	shl    $0x2,%eax
80103602:	01 d0                	add    %edx,%eax
80103604:	01 c0                	add    %eax,%eax
80103606:	8b 55 c8             	mov    -0x38(%ebp),%edx
80103609:	83 e2 0f             	and    $0xf,%edx
8010360c:	01 d0                	add    %edx,%eax
8010360e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103611:	8b 45 cc             	mov    -0x34(%ebp),%eax
80103614:	c1 e8 04             	shr    $0x4,%eax
80103617:	89 c2                	mov    %eax,%edx
80103619:	89 d0                	mov    %edx,%eax
8010361b:	c1 e0 02             	shl    $0x2,%eax
8010361e:	01 d0                	add    %edx,%eax
80103620:	01 c0                	add    %eax,%eax
80103622:	8b 55 cc             	mov    -0x34(%ebp),%edx
80103625:	83 e2 0f             	and    $0xf,%edx
80103628:	01 d0                	add    %edx,%eax
8010362a:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
8010362d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103630:	c1 e8 04             	shr    $0x4,%eax
80103633:	89 c2                	mov    %eax,%edx
80103635:	89 d0                	mov    %edx,%eax
80103637:	c1 e0 02             	shl    $0x2,%eax
8010363a:	01 d0                	add    %edx,%eax
8010363c:	01 c0                	add    %eax,%eax
8010363e:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103641:	83 e2 0f             	and    $0xf,%edx
80103644:	01 d0                	add    %edx,%eax
80103646:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
80103649:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010364c:	c1 e8 04             	shr    $0x4,%eax
8010364f:	89 c2                	mov    %eax,%edx
80103651:	89 d0                	mov    %edx,%eax
80103653:	c1 e0 02             	shl    $0x2,%eax
80103656:	01 d0                	add    %edx,%eax
80103658:	01 c0                	add    %eax,%eax
8010365a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010365d:	83 e2 0f             	and    $0xf,%edx
80103660:	01 d0                	add    %edx,%eax
80103662:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
80103665:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103668:	c1 e8 04             	shr    $0x4,%eax
8010366b:	89 c2                	mov    %eax,%edx
8010366d:	89 d0                	mov    %edx,%eax
8010366f:	c1 e0 02             	shl    $0x2,%eax
80103672:	01 d0                	add    %edx,%eax
80103674:	01 c0                	add    %eax,%eax
80103676:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103679:	83 e2 0f             	and    $0xf,%edx
8010367c:	01 d0                	add    %edx,%eax
8010367e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103681:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103684:	c1 e8 04             	shr    $0x4,%eax
80103687:	89 c2                	mov    %eax,%edx
80103689:	89 d0                	mov    %edx,%eax
8010368b:	c1 e0 02             	shl    $0x2,%eax
8010368e:	01 d0                	add    %edx,%eax
80103690:	01 c0                	add    %eax,%eax
80103692:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103695:	83 e2 0f             	and    $0xf,%edx
80103698:	01 d0                	add    %edx,%eax
8010369a:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
8010369d:	8b 45 08             	mov    0x8(%ebp),%eax
801036a0:	89 c2                	mov    %eax,%edx
801036a2:	8d 5d c8             	lea    -0x38(%ebp),%ebx
801036a5:	b8 06 00 00 00       	mov    $0x6,%eax
801036aa:	89 d7                	mov    %edx,%edi
801036ac:	89 de                	mov    %ebx,%esi
801036ae:	89 c1                	mov    %eax,%ecx
801036b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801036b2:	8b 45 08             	mov    0x8(%ebp),%eax
801036b5:	8b 40 14             	mov    0x14(%eax),%eax
801036b8:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801036be:	8b 45 08             	mov    0x8(%ebp),%eax
801036c1:	89 50 14             	mov    %edx,0x14(%eax)
}
801036c4:	83 c4 5c             	add    $0x5c,%esp
801036c7:	5b                   	pop    %ebx
801036c8:	5e                   	pop    %esi
801036c9:	5f                   	pop    %edi
801036ca:	5d                   	pop    %ebp
801036cb:	c3                   	ret    

801036cc <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
801036cc:	55                   	push   %ebp
801036cd:	89 e5                	mov    %esp,%ebp
801036cf:	83 ec 48             	sub    $0x48,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801036d2:	c7 44 24 04 e9 9d 10 	movl   $0x80109de9,0x4(%esp)
801036d9:	80 
801036da:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
801036e1:	e8 6c 1f 00 00       	call   80105652 <initlock>
  readsb(dev, &sb);
801036e6:	8d 45 d0             	lea    -0x30(%ebp),%eax
801036e9:	89 44 24 04          	mov    %eax,0x4(%esp)
801036ed:	8b 45 08             	mov    0x8(%ebp),%eax
801036f0:	89 04 24             	mov    %eax,(%esp)
801036f3:	e8 c8 dd ff ff       	call   801014c0 <readsb>
  log.start = sb.logstart;
801036f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801036fb:	a3 14 5c 11 80       	mov    %eax,0x80115c14
  log.size = sb.nlog;
80103700:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103703:	a3 18 5c 11 80       	mov    %eax,0x80115c18
  log.dev = dev;
80103708:	8b 45 08             	mov    0x8(%ebp),%eax
8010370b:	a3 24 5c 11 80       	mov    %eax,0x80115c24
  recover_from_log();
80103710:	e8 95 01 00 00       	call   801038aa <recover_from_log>
}
80103715:	c9                   	leave  
80103716:	c3                   	ret    

80103717 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80103717:	55                   	push   %ebp
80103718:	89 e5                	mov    %esp,%ebp
8010371a:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010371d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103724:	e9 89 00 00 00       	jmp    801037b2 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103729:	8b 15 14 5c 11 80    	mov    0x80115c14,%edx
8010372f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103732:	01 d0                	add    %edx,%eax
80103734:	40                   	inc    %eax
80103735:	89 c2                	mov    %eax,%edx
80103737:	a1 24 5c 11 80       	mov    0x80115c24,%eax
8010373c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103740:	89 04 24             	mov    %eax,(%esp)
80103743:	e8 6d ca ff ff       	call   801001b5 <bread>
80103748:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010374b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374e:	83 c0 10             	add    $0x10,%eax
80103751:	8b 04 85 ec 5b 11 80 	mov    -0x7feea414(,%eax,4),%eax
80103758:	89 c2                	mov    %eax,%edx
8010375a:	a1 24 5c 11 80       	mov    0x80115c24,%eax
8010375f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103763:	89 04 24             	mov    %eax,(%esp)
80103766:	e8 4a ca ff ff       	call   801001b5 <bread>
8010376b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010376e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103771:	8d 50 5c             	lea    0x5c(%eax),%edx
80103774:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103777:	83 c0 5c             	add    $0x5c,%eax
8010377a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103781:	00 
80103782:	89 54 24 04          	mov    %edx,0x4(%esp)
80103786:	89 04 24             	mov    %eax,(%esp)
80103789:	e8 11 22 00 00       	call   8010599f <memmove>
    bwrite(dbuf);  // write dst to disk
8010378e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103791:	89 04 24             	mov    %eax,(%esp)
80103794:	e8 53 ca ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103799:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010379c:	89 04 24             	mov    %eax,(%esp)
8010379f:	e8 88 ca ff ff       	call   8010022c <brelse>
    brelse(dbuf);
801037a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037a7:	89 04 24             	mov    %eax,(%esp)
801037aa:	e8 7d ca ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037af:	ff 45 f4             	incl   -0xc(%ebp)
801037b2:	a1 28 5c 11 80       	mov    0x80115c28,%eax
801037b7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037ba:	0f 8f 69 ff ff ff    	jg     80103729 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801037c0:	c9                   	leave  
801037c1:	c3                   	ret    

801037c2 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801037c2:	55                   	push   %ebp
801037c3:	89 e5                	mov    %esp,%ebp
801037c5:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801037c8:	a1 14 5c 11 80       	mov    0x80115c14,%eax
801037cd:	89 c2                	mov    %eax,%edx
801037cf:	a1 24 5c 11 80       	mov    0x80115c24,%eax
801037d4:	89 54 24 04          	mov    %edx,0x4(%esp)
801037d8:	89 04 24             	mov    %eax,(%esp)
801037db:	e8 d5 c9 ff ff       	call   801001b5 <bread>
801037e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801037e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037e6:	83 c0 5c             	add    $0x5c,%eax
801037e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801037ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037ef:	8b 00                	mov    (%eax),%eax
801037f1:	a3 28 5c 11 80       	mov    %eax,0x80115c28
  for (i = 0; i < log.lh.n; i++) {
801037f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037fd:	eb 1a                	jmp    80103819 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
801037ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103802:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103805:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103809:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010380c:	83 c2 10             	add    $0x10,%edx
8010380f:	89 04 95 ec 5b 11 80 	mov    %eax,-0x7feea414(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
80103816:	ff 45 f4             	incl   -0xc(%ebp)
80103819:	a1 28 5c 11 80       	mov    0x80115c28,%eax
8010381e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103821:	7f dc                	jg     801037ff <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103826:	89 04 24             	mov    %eax,(%esp)
80103829:	e8 fe c9 ff ff       	call   8010022c <brelse>
}
8010382e:	c9                   	leave  
8010382f:	c3                   	ret    

80103830 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103830:	55                   	push   %ebp
80103831:	89 e5                	mov    %esp,%ebp
80103833:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103836:	a1 14 5c 11 80       	mov    0x80115c14,%eax
8010383b:	89 c2                	mov    %eax,%edx
8010383d:	a1 24 5c 11 80       	mov    0x80115c24,%eax
80103842:	89 54 24 04          	mov    %edx,0x4(%esp)
80103846:	89 04 24             	mov    %eax,(%esp)
80103849:	e8 67 c9 ff ff       	call   801001b5 <bread>
8010384e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103854:	83 c0 5c             	add    $0x5c,%eax
80103857:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010385a:	8b 15 28 5c 11 80    	mov    0x80115c28,%edx
80103860:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103863:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103865:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010386c:	eb 1a                	jmp    80103888 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
8010386e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103871:	83 c0 10             	add    $0x10,%eax
80103874:	8b 0c 85 ec 5b 11 80 	mov    -0x7feea414(,%eax,4),%ecx
8010387b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010387e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103881:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103885:	ff 45 f4             	incl   -0xc(%ebp)
80103888:	a1 28 5c 11 80       	mov    0x80115c28,%eax
8010388d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103890:	7f dc                	jg     8010386e <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103892:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103895:	89 04 24             	mov    %eax,(%esp)
80103898:	e8 4f c9 ff ff       	call   801001ec <bwrite>
  brelse(buf);
8010389d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a0:	89 04 24             	mov    %eax,(%esp)
801038a3:	e8 84 c9 ff ff       	call   8010022c <brelse>
}
801038a8:	c9                   	leave  
801038a9:	c3                   	ret    

801038aa <recover_from_log>:

static void
recover_from_log(void)
{
801038aa:	55                   	push   %ebp
801038ab:	89 e5                	mov    %esp,%ebp
801038ad:	83 ec 08             	sub    $0x8,%esp
  read_head();
801038b0:	e8 0d ff ff ff       	call   801037c2 <read_head>
  install_trans(); // if committed, copy from log to disk
801038b5:	e8 5d fe ff ff       	call   80103717 <install_trans>
  log.lh.n = 0;
801038ba:	c7 05 28 5c 11 80 00 	movl   $0x0,0x80115c28
801038c1:	00 00 00 
  write_head(); // clear the log
801038c4:	e8 67 ff ff ff       	call   80103830 <write_head>
}
801038c9:	c9                   	leave  
801038ca:	c3                   	ret    

801038cb <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801038cb:	55                   	push   %ebp
801038cc:	89 e5                	mov    %esp,%ebp
801038ce:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801038d1:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
801038d8:	e8 96 1d 00 00       	call   80105673 <acquire>
  while(1){
    if(log.committing){
801038dd:	a1 20 5c 11 80       	mov    0x80115c20,%eax
801038e2:	85 c0                	test   %eax,%eax
801038e4:	74 16                	je     801038fc <begin_op+0x31>
      sleep(&log, &log.lock);
801038e6:	c7 44 24 04 e0 5b 11 	movl   $0x80115be0,0x4(%esp)
801038ed:	80 
801038ee:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
801038f5:	e8 29 16 00 00       	call   80104f23 <sleep>
801038fa:	eb 4d                	jmp    80103949 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801038fc:	8b 15 28 5c 11 80    	mov    0x80115c28,%edx
80103902:	a1 1c 5c 11 80       	mov    0x80115c1c,%eax
80103907:	8d 48 01             	lea    0x1(%eax),%ecx
8010390a:	89 c8                	mov    %ecx,%eax
8010390c:	c1 e0 02             	shl    $0x2,%eax
8010390f:	01 c8                	add    %ecx,%eax
80103911:	01 c0                	add    %eax,%eax
80103913:	01 d0                	add    %edx,%eax
80103915:	83 f8 1e             	cmp    $0x1e,%eax
80103918:	7e 16                	jle    80103930 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010391a:	c7 44 24 04 e0 5b 11 	movl   $0x80115be0,0x4(%esp)
80103921:	80 
80103922:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
80103929:	e8 f5 15 00 00       	call   80104f23 <sleep>
8010392e:	eb 19                	jmp    80103949 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103930:	a1 1c 5c 11 80       	mov    0x80115c1c,%eax
80103935:	40                   	inc    %eax
80103936:	a3 1c 5c 11 80       	mov    %eax,0x80115c1c
      release(&log.lock);
8010393b:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
80103942:	e8 96 1d 00 00       	call   801056dd <release>
      break;
80103947:	eb 02                	jmp    8010394b <begin_op+0x80>
    }
  }
80103949:	eb 92                	jmp    801038dd <begin_op+0x12>
}
8010394b:	c9                   	leave  
8010394c:	c3                   	ret    

8010394d <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010394d:	55                   	push   %ebp
8010394e:	89 e5                	mov    %esp,%ebp
80103950:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103953:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010395a:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
80103961:	e8 0d 1d 00 00       	call   80105673 <acquire>
  log.outstanding -= 1;
80103966:	a1 1c 5c 11 80       	mov    0x80115c1c,%eax
8010396b:	48                   	dec    %eax
8010396c:	a3 1c 5c 11 80       	mov    %eax,0x80115c1c
  if(log.committing)
80103971:	a1 20 5c 11 80       	mov    0x80115c20,%eax
80103976:	85 c0                	test   %eax,%eax
80103978:	74 0c                	je     80103986 <end_op+0x39>
    panic("log.committing");
8010397a:	c7 04 24 ed 9d 10 80 	movl   $0x80109ded,(%esp)
80103981:	e8 ce cb ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
80103986:	a1 1c 5c 11 80       	mov    0x80115c1c,%eax
8010398b:	85 c0                	test   %eax,%eax
8010398d:	75 13                	jne    801039a2 <end_op+0x55>
    do_commit = 1;
8010398f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103996:	c7 05 20 5c 11 80 01 	movl   $0x1,0x80115c20
8010399d:	00 00 00 
801039a0:	eb 0c                	jmp    801039ae <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801039a2:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
801039a9:	e8 4c 16 00 00       	call   80104ffa <wakeup>
  }
  release(&log.lock);
801039ae:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
801039b5:	e8 23 1d 00 00       	call   801056dd <release>

  if(do_commit){
801039ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801039be:	74 33                	je     801039f3 <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801039c0:	e8 db 00 00 00       	call   80103aa0 <commit>
    acquire(&log.lock);
801039c5:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
801039cc:	e8 a2 1c 00 00       	call   80105673 <acquire>
    log.committing = 0;
801039d1:	c7 05 20 5c 11 80 00 	movl   $0x0,0x80115c20
801039d8:	00 00 00 
    wakeup(&log);
801039db:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
801039e2:	e8 13 16 00 00       	call   80104ffa <wakeup>
    release(&log.lock);
801039e7:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
801039ee:	e8 ea 1c 00 00       	call   801056dd <release>
  }
}
801039f3:	c9                   	leave  
801039f4:	c3                   	ret    

801039f5 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801039f5:	55                   	push   %ebp
801039f6:	89 e5                	mov    %esp,%ebp
801039f8:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801039fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103a02:	e9 89 00 00 00       	jmp    80103a90 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103a07:	8b 15 14 5c 11 80    	mov    0x80115c14,%edx
80103a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a10:	01 d0                	add    %edx,%eax
80103a12:	40                   	inc    %eax
80103a13:	89 c2                	mov    %eax,%edx
80103a15:	a1 24 5c 11 80       	mov    0x80115c24,%eax
80103a1a:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a1e:	89 04 24             	mov    %eax,(%esp)
80103a21:	e8 8f c7 ff ff       	call   801001b5 <bread>
80103a26:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2c:	83 c0 10             	add    $0x10,%eax
80103a2f:	8b 04 85 ec 5b 11 80 	mov    -0x7feea414(,%eax,4),%eax
80103a36:	89 c2                	mov    %eax,%edx
80103a38:	a1 24 5c 11 80       	mov    0x80115c24,%eax
80103a3d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a41:	89 04 24             	mov    %eax,(%esp)
80103a44:	e8 6c c7 ff ff       	call   801001b5 <bread>
80103a49:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a4f:	8d 50 5c             	lea    0x5c(%eax),%edx
80103a52:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a55:	83 c0 5c             	add    $0x5c,%eax
80103a58:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103a5f:	00 
80103a60:	89 54 24 04          	mov    %edx,0x4(%esp)
80103a64:	89 04 24             	mov    %eax,(%esp)
80103a67:	e8 33 1f 00 00       	call   8010599f <memmove>
    bwrite(to);  // write the log
80103a6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a6f:	89 04 24             	mov    %eax,(%esp)
80103a72:	e8 75 c7 ff ff       	call   801001ec <bwrite>
    brelse(from);
80103a77:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a7a:	89 04 24             	mov    %eax,(%esp)
80103a7d:	e8 aa c7 ff ff       	call   8010022c <brelse>
    brelse(to);
80103a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a85:	89 04 24             	mov    %eax,(%esp)
80103a88:	e8 9f c7 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103a8d:	ff 45 f4             	incl   -0xc(%ebp)
80103a90:	a1 28 5c 11 80       	mov    0x80115c28,%eax
80103a95:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a98:	0f 8f 69 ff ff ff    	jg     80103a07 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103a9e:	c9                   	leave  
80103a9f:	c3                   	ret    

80103aa0 <commit>:

static void
commit()
{
80103aa0:	55                   	push   %ebp
80103aa1:	89 e5                	mov    %esp,%ebp
80103aa3:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103aa6:	a1 28 5c 11 80       	mov    0x80115c28,%eax
80103aab:	85 c0                	test   %eax,%eax
80103aad:	7e 1e                	jle    80103acd <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103aaf:	e8 41 ff ff ff       	call   801039f5 <write_log>
    write_head();    // Write header to disk -- the real commit
80103ab4:	e8 77 fd ff ff       	call   80103830 <write_head>
    install_trans(); // Now install writes to home locations
80103ab9:	e8 59 fc ff ff       	call   80103717 <install_trans>
    log.lh.n = 0;
80103abe:	c7 05 28 5c 11 80 00 	movl   $0x0,0x80115c28
80103ac5:	00 00 00 
    write_head();    // Erase the transaction from the log
80103ac8:	e8 63 fd ff ff       	call   80103830 <write_head>
  }
}
80103acd:	c9                   	leave  
80103ace:	c3                   	ret    

80103acf <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103acf:	55                   	push   %ebp
80103ad0:	89 e5                	mov    %esp,%ebp
80103ad2:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103ad5:	a1 28 5c 11 80       	mov    0x80115c28,%eax
80103ada:	83 f8 1d             	cmp    $0x1d,%eax
80103add:	7f 10                	jg     80103aef <log_write+0x20>
80103adf:	a1 28 5c 11 80       	mov    0x80115c28,%eax
80103ae4:	8b 15 18 5c 11 80    	mov    0x80115c18,%edx
80103aea:	4a                   	dec    %edx
80103aeb:	39 d0                	cmp    %edx,%eax
80103aed:	7c 0c                	jl     80103afb <log_write+0x2c>
    panic("too big a transaction");
80103aef:	c7 04 24 fc 9d 10 80 	movl   $0x80109dfc,(%esp)
80103af6:	e8 59 ca ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103afb:	a1 1c 5c 11 80       	mov    0x80115c1c,%eax
80103b00:	85 c0                	test   %eax,%eax
80103b02:	7f 0c                	jg     80103b10 <log_write+0x41>
    panic("log_write outside of trans");
80103b04:	c7 04 24 12 9e 10 80 	movl   $0x80109e12,(%esp)
80103b0b:	e8 44 ca ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103b10:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
80103b17:	e8 57 1b 00 00       	call   80105673 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103b1c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103b23:	eb 1e                	jmp    80103b43 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b28:	83 c0 10             	add    $0x10,%eax
80103b2b:	8b 04 85 ec 5b 11 80 	mov    -0x7feea414(,%eax,4),%eax
80103b32:	89 c2                	mov    %eax,%edx
80103b34:	8b 45 08             	mov    0x8(%ebp),%eax
80103b37:	8b 40 08             	mov    0x8(%eax),%eax
80103b3a:	39 c2                	cmp    %eax,%edx
80103b3c:	75 02                	jne    80103b40 <log_write+0x71>
      break;
80103b3e:	eb 0d                	jmp    80103b4d <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103b40:	ff 45 f4             	incl   -0xc(%ebp)
80103b43:	a1 28 5c 11 80       	mov    0x80115c28,%eax
80103b48:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b4b:	7f d8                	jg     80103b25 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103b4d:	8b 45 08             	mov    0x8(%ebp),%eax
80103b50:	8b 40 08             	mov    0x8(%eax),%eax
80103b53:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b56:	83 c2 10             	add    $0x10,%edx
80103b59:	89 04 95 ec 5b 11 80 	mov    %eax,-0x7feea414(,%edx,4)
  if (i == log.lh.n)
80103b60:	a1 28 5c 11 80       	mov    0x80115c28,%eax
80103b65:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b68:	75 0b                	jne    80103b75 <log_write+0xa6>
    log.lh.n++;
80103b6a:	a1 28 5c 11 80       	mov    0x80115c28,%eax
80103b6f:	40                   	inc    %eax
80103b70:	a3 28 5c 11 80       	mov    %eax,0x80115c28
  b->flags |= B_DIRTY; // prevent eviction
80103b75:	8b 45 08             	mov    0x8(%ebp),%eax
80103b78:	8b 00                	mov    (%eax),%eax
80103b7a:	83 c8 04             	or     $0x4,%eax
80103b7d:	89 c2                	mov    %eax,%edx
80103b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b82:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103b84:	c7 04 24 e0 5b 11 80 	movl   $0x80115be0,(%esp)
80103b8b:	e8 4d 1b 00 00       	call   801056dd <release>
}
80103b90:	c9                   	leave  
80103b91:	c3                   	ret    
	...

80103b94 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103b94:	55                   	push   %ebp
80103b95:	89 e5                	mov    %esp,%ebp
80103b97:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103b9a:	8b 55 08             	mov    0x8(%ebp),%edx
80103b9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ba0:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103ba3:	f0 87 02             	lock xchg %eax,(%edx)
80103ba6:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103ba9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103bac:	c9                   	leave  
80103bad:	c3                   	ret    

80103bae <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103bae:	55                   	push   %ebp
80103baf:	89 e5                	mov    %esp,%ebp
80103bb1:	83 e4 f0             	and    $0xfffffff0,%esp
80103bb4:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103bb7:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103bbe:	80 
80103bbf:	c7 04 24 10 8e 11 80 	movl   $0x80118e10,(%esp)
80103bc6:	e8 dd f1 ff ff       	call   80102da8 <kinit1>
  kvmalloc();      // kernel page table
80103bcb:	e8 4f 4e 00 00       	call   80108a1f <kvmalloc>
  mpinit();        // detect other processors
80103bd0:	e8 cc 03 00 00       	call   80103fa1 <mpinit>
  lapicinit();     // interrupt controller
80103bd5:	e8 4e f6 ff ff       	call   80103228 <lapicinit>
  seginit();       // segment descriptors
80103bda:	e8 28 49 00 00       	call   80108507 <seginit>
  picinit();       // disable pic
80103bdf:	e8 0c 05 00 00       	call   801040f0 <picinit>
  ioapicinit();    // another interrupt controller
80103be4:	e8 dc f0 ff ff       	call   80102cc5 <ioapicinit>
  consoleinit();   // console hardware
80103be9:	e8 01 d0 ff ff       	call   80100bef <consoleinit>
  uartinit();      // serial port
80103bee:	e8 a0 3c 00 00       	call   80107893 <uartinit>
  pinit();         // process table
80103bf3:	e8 ee 08 00 00       	call   801044e6 <pinit>
  tvinit();        // trap vectors
80103bf8:	e8 63 38 00 00       	call   80107460 <tvinit>
  binit();         // buffer cache
80103bfd:	e8 32 c4 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103c02:	e8 df d4 ff ff       	call   801010e6 <fileinit>
  ideinit();       // disk 
80103c07:	e8 c5 ec ff ff       	call   801028d1 <ideinit>
  startothers();   // start other processors
80103c0c:	e8 88 00 00 00       	call   80103c99 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103c11:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103c18:	8e 
80103c19:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103c20:	e8 bb f1 ff ff       	call   80102de0 <kinit2>
  userinit();      // first user process
80103c25:	e8 e6 0a 00 00       	call   80104710 <userinit>
  container_init();
80103c2a:	e8 c5 5c 00 00       	call   801098f4 <container_init>
  mpmain();        // finish this processor's setup
80103c2f:	e8 1a 00 00 00       	call   80103c4e <mpmain>

80103c34 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103c34:	55                   	push   %ebp
80103c35:	89 e5                	mov    %esp,%ebp
80103c37:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103c3a:	e8 f7 4d 00 00       	call   80108a36 <switchkvm>
  seginit();
80103c3f:	e8 c3 48 00 00       	call   80108507 <seginit>
  lapicinit();
80103c44:	e8 df f5 ff ff       	call   80103228 <lapicinit>
  mpmain();
80103c49:	e8 00 00 00 00       	call   80103c4e <mpmain>

80103c4e <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103c4e:	55                   	push   %ebp
80103c4f:	89 e5                	mov    %esp,%ebp
80103c51:	53                   	push   %ebx
80103c52:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103c55:	e8 a8 08 00 00       	call   80104502 <cpuid>
80103c5a:	89 c3                	mov    %eax,%ebx
80103c5c:	e8 a1 08 00 00       	call   80104502 <cpuid>
80103c61:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103c65:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c69:	c7 04 24 2d 9e 10 80 	movl   $0x80109e2d,(%esp)
80103c70:	e8 4c c7 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103c75:	e8 43 39 00 00       	call   801075bd <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103c7a:	e8 c8 08 00 00       	call   80104547 <mycpu>
80103c7f:	05 a0 00 00 00       	add    $0xa0,%eax
80103c84:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103c8b:	00 
80103c8c:	89 04 24             	mov    %eax,(%esp)
80103c8f:	e8 00 ff ff ff       	call   80103b94 <xchg>
  scheduler();     // start running processes
80103c94:	e8 16 10 00 00       	call   80104caf <scheduler>

80103c99 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103c99:	55                   	push   %ebp
80103c9a:	89 e5                	mov    %esp,%ebp
80103c9c:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103c9f:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103ca6:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103cab:	89 44 24 08          	mov    %eax,0x8(%esp)
80103caf:	c7 44 24 04 8c d5 10 	movl   $0x8010d58c,0x4(%esp)
80103cb6:	80 
80103cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cba:	89 04 24             	mov    %eax,(%esp)
80103cbd:	e8 dd 1c 00 00       	call   8010599f <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103cc2:	c7 45 f4 e0 5c 11 80 	movl   $0x80115ce0,-0xc(%ebp)
80103cc9:	eb 75                	jmp    80103d40 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103ccb:	e8 77 08 00 00       	call   80104547 <mycpu>
80103cd0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103cd3:	75 02                	jne    80103cd7 <startothers+0x3e>
      continue;
80103cd5:	eb 62                	jmp    80103d39 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103cd7:	e8 5a f2 ff ff       	call   80102f36 <kalloc>
80103cdc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103cdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce2:	83 e8 04             	sub    $0x4,%eax
80103ce5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103ce8:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103cee:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103cf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf3:	83 e8 08             	sub    $0x8,%eax
80103cf6:	c7 00 34 3c 10 80    	movl   $0x80103c34,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cff:	8d 50 f4             	lea    -0xc(%eax),%edx
80103d02:	b8 00 c0 10 80       	mov    $0x8010c000,%eax
80103d07:	05 00 00 00 80       	add    $0x80000000,%eax
80103d0c:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103d0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d11:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103d17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d1a:	8a 00                	mov    (%eax),%al
80103d1c:	0f b6 c0             	movzbl %al,%eax
80103d1f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103d23:	89 04 24             	mov    %eax,(%esp)
80103d26:	e8 a2 f6 ff ff       	call   801033cd <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103d2b:	90                   	nop
80103d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d2f:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103d35:	85 c0                	test   %eax,%eax
80103d37:	74 f3                	je     80103d2c <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103d39:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103d40:	a1 60 62 11 80       	mov    0x80116260,%eax
80103d45:	89 c2                	mov    %eax,%edx
80103d47:	89 d0                	mov    %edx,%eax
80103d49:	c1 e0 02             	shl    $0x2,%eax
80103d4c:	01 d0                	add    %edx,%eax
80103d4e:	01 c0                	add    %eax,%eax
80103d50:	01 d0                	add    %edx,%eax
80103d52:	c1 e0 04             	shl    $0x4,%eax
80103d55:	05 e0 5c 11 80       	add    $0x80115ce0,%eax
80103d5a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103d5d:	0f 87 68 ff ff ff    	ja     80103ccb <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103d63:	c9                   	leave  
80103d64:	c3                   	ret    
80103d65:	00 00                	add    %al,(%eax)
	...

80103d68 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103d68:	55                   	push   %ebp
80103d69:	89 e5                	mov    %esp,%ebp
80103d6b:	83 ec 14             	sub    $0x14,%esp
80103d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d71:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103d75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d78:	89 c2                	mov    %eax,%edx
80103d7a:	ec                   	in     (%dx),%al
80103d7b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103d7e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103d81:	c9                   	leave  
80103d82:	c3                   	ret    

80103d83 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d83:	55                   	push   %ebp
80103d84:	89 e5                	mov    %esp,%ebp
80103d86:	83 ec 08             	sub    $0x8,%esp
80103d89:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d8f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d93:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d96:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d99:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d9c:	ee                   	out    %al,(%dx)
}
80103d9d:	c9                   	leave  
80103d9e:	c3                   	ret    

80103d9f <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103d9f:	55                   	push   %ebp
80103da0:	89 e5                	mov    %esp,%ebp
80103da2:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103da5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103dac:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103db3:	eb 13                	jmp    80103dc8 <sum+0x29>
    sum += addr[i];
80103db5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103db8:	8b 45 08             	mov    0x8(%ebp),%eax
80103dbb:	01 d0                	add    %edx,%eax
80103dbd:	8a 00                	mov    (%eax),%al
80103dbf:	0f b6 c0             	movzbl %al,%eax
80103dc2:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103dc5:	ff 45 fc             	incl   -0x4(%ebp)
80103dc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103dcb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103dce:	7c e5                	jl     80103db5 <sum+0x16>
    sum += addr[i];
  return sum;
80103dd0:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103dd3:	c9                   	leave  
80103dd4:	c3                   	ret    

80103dd5 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103dd5:	55                   	push   %ebp
80103dd6:	89 e5                	mov    %esp,%ebp
80103dd8:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103ddb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dde:	05 00 00 00 80       	add    $0x80000000,%eax
80103de3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103de6:	8b 55 0c             	mov    0xc(%ebp),%edx
80103de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103dec:	01 d0                	add    %edx,%eax
80103dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103df4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103df7:	eb 3f                	jmp    80103e38 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103df9:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103e00:	00 
80103e01:	c7 44 24 04 44 9e 10 	movl   $0x80109e44,0x4(%esp)
80103e08:	80 
80103e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0c:	89 04 24             	mov    %eax,(%esp)
80103e0f:	e8 39 1b 00 00       	call   8010594d <memcmp>
80103e14:	85 c0                	test   %eax,%eax
80103e16:	75 1c                	jne    80103e34 <mpsearch1+0x5f>
80103e18:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103e1f:	00 
80103e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e23:	89 04 24             	mov    %eax,(%esp)
80103e26:	e8 74 ff ff ff       	call   80103d9f <sum>
80103e2b:	84 c0                	test   %al,%al
80103e2d:	75 05                	jne    80103e34 <mpsearch1+0x5f>
      return (struct mp*)p;
80103e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e32:	eb 11                	jmp    80103e45 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103e34:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e3e:	72 b9                	jb     80103df9 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103e40:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e45:	c9                   	leave  
80103e46:	c3                   	ret    

80103e47 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103e47:	55                   	push   %ebp
80103e48:	89 e5                	mov    %esp,%ebp
80103e4a:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103e4d:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e57:	83 c0 0f             	add    $0xf,%eax
80103e5a:	8a 00                	mov    (%eax),%al
80103e5c:	0f b6 c0             	movzbl %al,%eax
80103e5f:	c1 e0 08             	shl    $0x8,%eax
80103e62:	89 c2                	mov    %eax,%edx
80103e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e67:	83 c0 0e             	add    $0xe,%eax
80103e6a:	8a 00                	mov    (%eax),%al
80103e6c:	0f b6 c0             	movzbl %al,%eax
80103e6f:	09 d0                	or     %edx,%eax
80103e71:	c1 e0 04             	shl    $0x4,%eax
80103e74:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103e77:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e7b:	74 21                	je     80103e9e <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103e7d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103e84:	00 
80103e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103e88:	89 04 24             	mov    %eax,(%esp)
80103e8b:	e8 45 ff ff ff       	call   80103dd5 <mpsearch1>
80103e90:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103e93:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103e97:	74 4e                	je     80103ee7 <mpsearch+0xa0>
      return mp;
80103e99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e9c:	eb 5d                	jmp    80103efb <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea1:	83 c0 14             	add    $0x14,%eax
80103ea4:	8a 00                	mov    (%eax),%al
80103ea6:	0f b6 c0             	movzbl %al,%eax
80103ea9:	c1 e0 08             	shl    $0x8,%eax
80103eac:	89 c2                	mov    %eax,%edx
80103eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb1:	83 c0 13             	add    $0x13,%eax
80103eb4:	8a 00                	mov    (%eax),%al
80103eb6:	0f b6 c0             	movzbl %al,%eax
80103eb9:	09 d0                	or     %edx,%eax
80103ebb:	c1 e0 0a             	shl    $0xa,%eax
80103ebe:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103ec1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ec4:	2d 00 04 00 00       	sub    $0x400,%eax
80103ec9:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ed0:	00 
80103ed1:	89 04 24             	mov    %eax,(%esp)
80103ed4:	e8 fc fe ff ff       	call   80103dd5 <mpsearch1>
80103ed9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103edc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ee0:	74 05                	je     80103ee7 <mpsearch+0xa0>
      return mp;
80103ee2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee5:	eb 14                	jmp    80103efb <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103ee7:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103eee:	00 
80103eef:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103ef6:	e8 da fe ff ff       	call   80103dd5 <mpsearch1>
}
80103efb:	c9                   	leave  
80103efc:	c3                   	ret    

80103efd <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103efd:	55                   	push   %ebp
80103efe:	89 e5                	mov    %esp,%ebp
80103f00:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103f03:	e8 3f ff ff ff       	call   80103e47 <mpsearch>
80103f08:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f0b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f0f:	74 0a                	je     80103f1b <mpconfig+0x1e>
80103f11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f14:	8b 40 04             	mov    0x4(%eax),%eax
80103f17:	85 c0                	test   %eax,%eax
80103f19:	75 07                	jne    80103f22 <mpconfig+0x25>
    return 0;
80103f1b:	b8 00 00 00 00       	mov    $0x0,%eax
80103f20:	eb 7d                	jmp    80103f9f <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f25:	8b 40 04             	mov    0x4(%eax),%eax
80103f28:	05 00 00 00 80       	add    $0x80000000,%eax
80103f2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103f30:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103f37:	00 
80103f38:	c7 44 24 04 49 9e 10 	movl   $0x80109e49,0x4(%esp)
80103f3f:	80 
80103f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f43:	89 04 24             	mov    %eax,(%esp)
80103f46:	e8 02 1a 00 00       	call   8010594d <memcmp>
80103f4b:	85 c0                	test   %eax,%eax
80103f4d:	74 07                	je     80103f56 <mpconfig+0x59>
    return 0;
80103f4f:	b8 00 00 00 00       	mov    $0x0,%eax
80103f54:	eb 49                	jmp    80103f9f <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103f56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f59:	8a 40 06             	mov    0x6(%eax),%al
80103f5c:	3c 01                	cmp    $0x1,%al
80103f5e:	74 11                	je     80103f71 <mpconfig+0x74>
80103f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f63:	8a 40 06             	mov    0x6(%eax),%al
80103f66:	3c 04                	cmp    $0x4,%al
80103f68:	74 07                	je     80103f71 <mpconfig+0x74>
    return 0;
80103f6a:	b8 00 00 00 00       	mov    $0x0,%eax
80103f6f:	eb 2e                	jmp    80103f9f <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103f71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f74:	8b 40 04             	mov    0x4(%eax),%eax
80103f77:	0f b7 c0             	movzwl %ax,%eax
80103f7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103f7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103f81:	89 04 24             	mov    %eax,(%esp)
80103f84:	e8 16 fe ff ff       	call   80103d9f <sum>
80103f89:	84 c0                	test   %al,%al
80103f8b:	74 07                	je     80103f94 <mpconfig+0x97>
    return 0;
80103f8d:	b8 00 00 00 00       	mov    $0x0,%eax
80103f92:	eb 0b                	jmp    80103f9f <mpconfig+0xa2>
  *pmp = mp;
80103f94:	8b 45 08             	mov    0x8(%ebp),%eax
80103f97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f9a:	89 10                	mov    %edx,(%eax)
  return conf;
80103f9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103f9f:	c9                   	leave  
80103fa0:	c3                   	ret    

80103fa1 <mpinit>:

void
mpinit(void)
{
80103fa1:	55                   	push   %ebp
80103fa2:	89 e5                	mov    %esp,%ebp
80103fa4:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103fa7:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103faa:	89 04 24             	mov    %eax,(%esp)
80103fad:	e8 4b ff ff ff       	call   80103efd <mpconfig>
80103fb2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103fb5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103fb9:	75 0c                	jne    80103fc7 <mpinit+0x26>
    panic("Expect to run on an SMP");
80103fbb:	c7 04 24 4e 9e 10 80 	movl   $0x80109e4e,(%esp)
80103fc2:	e8 8d c5 ff ff       	call   80100554 <panic>
  ismp = 1;
80103fc7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103fce:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fd1:	8b 40 24             	mov    0x24(%eax),%eax
80103fd4:	a3 c0 5b 11 80       	mov    %eax,0x80115bc0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103fd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fdc:	83 c0 2c             	add    $0x2c,%eax
80103fdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fe2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fe5:	8b 40 04             	mov    0x4(%eax),%eax
80103fe8:	0f b7 d0             	movzwl %ax,%edx
80103feb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fee:	01 d0                	add    %edx,%eax
80103ff0:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103ff3:	eb 7d                	jmp    80104072 <mpinit+0xd1>
    switch(*p){
80103ff5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff8:	8a 00                	mov    (%eax),%al
80103ffa:	0f b6 c0             	movzbl %al,%eax
80103ffd:	83 f8 04             	cmp    $0x4,%eax
80104000:	77 68                	ja     8010406a <mpinit+0xc9>
80104002:	8b 04 85 88 9e 10 80 	mov    -0x7fef6178(,%eax,4),%eax
80104009:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
8010400b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80104011:	a1 60 62 11 80       	mov    0x80116260,%eax
80104016:	83 f8 07             	cmp    $0x7,%eax
80104019:	7f 2c                	jg     80104047 <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010401b:	8b 15 60 62 11 80    	mov    0x80116260,%edx
80104021:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104024:	8a 48 01             	mov    0x1(%eax),%cl
80104027:	89 d0                	mov    %edx,%eax
80104029:	c1 e0 02             	shl    $0x2,%eax
8010402c:	01 d0                	add    %edx,%eax
8010402e:	01 c0                	add    %eax,%eax
80104030:	01 d0                	add    %edx,%eax
80104032:	c1 e0 04             	shl    $0x4,%eax
80104035:	05 e0 5c 11 80       	add    $0x80115ce0,%eax
8010403a:	88 08                	mov    %cl,(%eax)
        ncpu++;
8010403c:	a1 60 62 11 80       	mov    0x80116260,%eax
80104041:	40                   	inc    %eax
80104042:	a3 60 62 11 80       	mov    %eax,0x80116260
      }
      p += sizeof(struct mpproc);
80104047:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
8010404b:	eb 25                	jmp    80104072 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
8010404d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104050:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80104053:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104056:	8a 40 01             	mov    0x1(%eax),%al
80104059:	a2 c0 5c 11 80       	mov    %al,0x80115cc0
      p += sizeof(struct mpioapic);
8010405e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104062:	eb 0e                	jmp    80104072 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80104064:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80104068:	eb 08                	jmp    80104072 <mpinit+0xd1>
    default:
      ismp = 0;
8010406a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80104071:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80104072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104075:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80104078:	0f 82 77 ff ff ff    	jb     80103ff5 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
8010407e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104082:	75 0c                	jne    80104090 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80104084:	c7 04 24 68 9e 10 80 	movl   $0x80109e68,(%esp)
8010408b:	e8 c4 c4 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80104090:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104093:	8a 40 0c             	mov    0xc(%eax),%al
80104096:	84 c0                	test   %al,%al
80104098:	74 36                	je     801040d0 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
8010409a:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
801040a1:	00 
801040a2:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
801040a9:	e8 d5 fc ff ff       	call   80103d83 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
801040ae:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
801040b5:	e8 ae fc ff ff       	call   80103d68 <inb>
801040ba:	83 c8 01             	or     $0x1,%eax
801040bd:	0f b6 c0             	movzbl %al,%eax
801040c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801040c4:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
801040cb:	e8 b3 fc ff ff       	call   80103d83 <outb>
  }
}
801040d0:	c9                   	leave  
801040d1:	c3                   	ret    
	...

801040d4 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801040d4:	55                   	push   %ebp
801040d5:	89 e5                	mov    %esp,%ebp
801040d7:	83 ec 08             	sub    $0x8,%esp
801040da:	8b 45 08             	mov    0x8(%ebp),%eax
801040dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801040e0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801040e4:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801040e7:	8a 45 f8             	mov    -0x8(%ebp),%al
801040ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
801040ed:	ee                   	out    %al,(%dx)
}
801040ee:	c9                   	leave  
801040ef:	c3                   	ret    

801040f0 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
801040f0:	55                   	push   %ebp
801040f1:	89 e5                	mov    %esp,%ebp
801040f3:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
801040f6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
801040fd:	00 
801040fe:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80104105:	e8 ca ff ff ff       	call   801040d4 <outb>
  outb(IO_PIC2+1, 0xFF);
8010410a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80104111:	00 
80104112:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80104119:	e8 b6 ff ff ff       	call   801040d4 <outb>
}
8010411e:	c9                   	leave  
8010411f:	c3                   	ret    

80104120 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104120:	55                   	push   %ebp
80104121:	89 e5                	mov    %esp,%ebp
80104123:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80104126:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010412d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104130:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80104136:	8b 45 0c             	mov    0xc(%ebp),%eax
80104139:	8b 10                	mov    (%eax),%edx
8010413b:	8b 45 08             	mov    0x8(%ebp),%eax
8010413e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104140:	e8 bd cf ff ff       	call   80101102 <filealloc>
80104145:	8b 55 08             	mov    0x8(%ebp),%edx
80104148:	89 02                	mov    %eax,(%edx)
8010414a:	8b 45 08             	mov    0x8(%ebp),%eax
8010414d:	8b 00                	mov    (%eax),%eax
8010414f:	85 c0                	test   %eax,%eax
80104151:	0f 84 c8 00 00 00    	je     8010421f <pipealloc+0xff>
80104157:	e8 a6 cf ff ff       	call   80101102 <filealloc>
8010415c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010415f:	89 02                	mov    %eax,(%edx)
80104161:	8b 45 0c             	mov    0xc(%ebp),%eax
80104164:	8b 00                	mov    (%eax),%eax
80104166:	85 c0                	test   %eax,%eax
80104168:	0f 84 b1 00 00 00    	je     8010421f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010416e:	e8 c3 ed ff ff       	call   80102f36 <kalloc>
80104173:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104176:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010417a:	75 05                	jne    80104181 <pipealloc+0x61>
    goto bad;
8010417c:	e9 9e 00 00 00       	jmp    8010421f <pipealloc+0xff>
  p->readopen = 1;
80104181:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104184:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010418b:	00 00 00 
  p->writeopen = 1;
8010418e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104191:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80104198:	00 00 00 
  p->nwrite = 0;
8010419b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010419e:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801041a5:	00 00 00 
  p->nread = 0;
801041a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ab:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801041b2:	00 00 00 
  initlock(&p->lock, "pipe");
801041b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b8:	c7 44 24 04 9c 9e 10 	movl   $0x80109e9c,0x4(%esp)
801041bf:	80 
801041c0:	89 04 24             	mov    %eax,(%esp)
801041c3:	e8 8a 14 00 00       	call   80105652 <initlock>
  (*f0)->type = FD_PIPE;
801041c8:	8b 45 08             	mov    0x8(%ebp),%eax
801041cb:	8b 00                	mov    (%eax),%eax
801041cd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801041d3:	8b 45 08             	mov    0x8(%ebp),%eax
801041d6:	8b 00                	mov    (%eax),%eax
801041d8:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801041dc:	8b 45 08             	mov    0x8(%ebp),%eax
801041df:	8b 00                	mov    (%eax),%eax
801041e1:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801041e5:	8b 45 08             	mov    0x8(%ebp),%eax
801041e8:	8b 00                	mov    (%eax),%eax
801041ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ed:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801041f0:	8b 45 0c             	mov    0xc(%ebp),%eax
801041f3:	8b 00                	mov    (%eax),%eax
801041f5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801041fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801041fe:	8b 00                	mov    (%eax),%eax
80104200:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104204:	8b 45 0c             	mov    0xc(%ebp),%eax
80104207:	8b 00                	mov    (%eax),%eax
80104209:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010420d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104210:	8b 00                	mov    (%eax),%eax
80104212:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104215:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104218:	b8 00 00 00 00       	mov    $0x0,%eax
8010421d:	eb 42                	jmp    80104261 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
8010421f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104223:	74 0b                	je     80104230 <pipealloc+0x110>
    kfree((char*)p);
80104225:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104228:	89 04 24             	mov    %eax,(%esp)
8010422b:	e8 17 ec ff ff       	call   80102e47 <kfree>
  if(*f0)
80104230:	8b 45 08             	mov    0x8(%ebp),%eax
80104233:	8b 00                	mov    (%eax),%eax
80104235:	85 c0                	test   %eax,%eax
80104237:	74 0d                	je     80104246 <pipealloc+0x126>
    fileclose(*f0);
80104239:	8b 45 08             	mov    0x8(%ebp),%eax
8010423c:	8b 00                	mov    (%eax),%eax
8010423e:	89 04 24             	mov    %eax,(%esp)
80104241:	e8 64 cf ff ff       	call   801011aa <fileclose>
  if(*f1)
80104246:	8b 45 0c             	mov    0xc(%ebp),%eax
80104249:	8b 00                	mov    (%eax),%eax
8010424b:	85 c0                	test   %eax,%eax
8010424d:	74 0d                	je     8010425c <pipealloc+0x13c>
    fileclose(*f1);
8010424f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104252:	8b 00                	mov    (%eax),%eax
80104254:	89 04 24             	mov    %eax,(%esp)
80104257:	e8 4e cf ff ff       	call   801011aa <fileclose>
  return -1;
8010425c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104261:	c9                   	leave  
80104262:	c3                   	ret    

80104263 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104263:	55                   	push   %ebp
80104264:	89 e5                	mov    %esp,%ebp
80104266:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104269:	8b 45 08             	mov    0x8(%ebp),%eax
8010426c:	89 04 24             	mov    %eax,(%esp)
8010426f:	e8 ff 13 00 00       	call   80105673 <acquire>
  if(writable){
80104274:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104278:	74 1f                	je     80104299 <pipeclose+0x36>
    p->writeopen = 0;
8010427a:	8b 45 08             	mov    0x8(%ebp),%eax
8010427d:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104284:	00 00 00 
    wakeup(&p->nread);
80104287:	8b 45 08             	mov    0x8(%ebp),%eax
8010428a:	05 34 02 00 00       	add    $0x234,%eax
8010428f:	89 04 24             	mov    %eax,(%esp)
80104292:	e8 63 0d 00 00       	call   80104ffa <wakeup>
80104297:	eb 1d                	jmp    801042b6 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104299:	8b 45 08             	mov    0x8(%ebp),%eax
8010429c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801042a3:	00 00 00 
    wakeup(&p->nwrite);
801042a6:	8b 45 08             	mov    0x8(%ebp),%eax
801042a9:	05 38 02 00 00       	add    $0x238,%eax
801042ae:	89 04 24             	mov    %eax,(%esp)
801042b1:	e8 44 0d 00 00       	call   80104ffa <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801042b6:	8b 45 08             	mov    0x8(%ebp),%eax
801042b9:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042bf:	85 c0                	test   %eax,%eax
801042c1:	75 25                	jne    801042e8 <pipeclose+0x85>
801042c3:	8b 45 08             	mov    0x8(%ebp),%eax
801042c6:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801042cc:	85 c0                	test   %eax,%eax
801042ce:	75 18                	jne    801042e8 <pipeclose+0x85>
    release(&p->lock);
801042d0:	8b 45 08             	mov    0x8(%ebp),%eax
801042d3:	89 04 24             	mov    %eax,(%esp)
801042d6:	e8 02 14 00 00       	call   801056dd <release>
    kfree((char*)p);
801042db:	8b 45 08             	mov    0x8(%ebp),%eax
801042de:	89 04 24             	mov    %eax,(%esp)
801042e1:	e8 61 eb ff ff       	call   80102e47 <kfree>
801042e6:	eb 0b                	jmp    801042f3 <pipeclose+0x90>
  } else
    release(&p->lock);
801042e8:	8b 45 08             	mov    0x8(%ebp),%eax
801042eb:	89 04 24             	mov    %eax,(%esp)
801042ee:	e8 ea 13 00 00       	call   801056dd <release>
}
801042f3:	c9                   	leave  
801042f4:	c3                   	ret    

801042f5 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801042f5:	55                   	push   %ebp
801042f6:	89 e5                	mov    %esp,%ebp
801042f8:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801042fb:	8b 45 08             	mov    0x8(%ebp),%eax
801042fe:	89 04 24             	mov    %eax,(%esp)
80104301:	e8 6d 13 00 00       	call   80105673 <acquire>
  for(i = 0; i < n; i++){
80104306:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010430d:	e9 a3 00 00 00       	jmp    801043b5 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104312:	eb 56                	jmp    8010436a <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80104314:	8b 45 08             	mov    0x8(%ebp),%eax
80104317:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010431d:	85 c0                	test   %eax,%eax
8010431f:	74 0c                	je     8010432d <pipewrite+0x38>
80104321:	e8 a5 02 00 00       	call   801045cb <myproc>
80104326:	8b 40 24             	mov    0x24(%eax),%eax
80104329:	85 c0                	test   %eax,%eax
8010432b:	74 15                	je     80104342 <pipewrite+0x4d>
        release(&p->lock);
8010432d:	8b 45 08             	mov    0x8(%ebp),%eax
80104330:	89 04 24             	mov    %eax,(%esp)
80104333:	e8 a5 13 00 00       	call   801056dd <release>
        return -1;
80104338:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010433d:	e9 9d 00 00 00       	jmp    801043df <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104342:	8b 45 08             	mov    0x8(%ebp),%eax
80104345:	05 34 02 00 00       	add    $0x234,%eax
8010434a:	89 04 24             	mov    %eax,(%esp)
8010434d:	e8 a8 0c 00 00       	call   80104ffa <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104352:	8b 45 08             	mov    0x8(%ebp),%eax
80104355:	8b 55 08             	mov    0x8(%ebp),%edx
80104358:	81 c2 38 02 00 00    	add    $0x238,%edx
8010435e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104362:	89 14 24             	mov    %edx,(%esp)
80104365:	e8 b9 0b 00 00       	call   80104f23 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010436a:	8b 45 08             	mov    0x8(%ebp),%eax
8010436d:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104373:	8b 45 08             	mov    0x8(%ebp),%eax
80104376:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010437c:	05 00 02 00 00       	add    $0x200,%eax
80104381:	39 c2                	cmp    %eax,%edx
80104383:	74 8f                	je     80104314 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104385:	8b 45 08             	mov    0x8(%ebp),%eax
80104388:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010438e:	8d 48 01             	lea    0x1(%eax),%ecx
80104391:	8b 55 08             	mov    0x8(%ebp),%edx
80104394:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010439a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010439f:	89 c1                	mov    %eax,%ecx
801043a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801043a7:	01 d0                	add    %edx,%eax
801043a9:	8a 10                	mov    (%eax),%dl
801043ab:	8b 45 08             	mov    0x8(%ebp),%eax
801043ae:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801043b2:	ff 45 f4             	incl   -0xc(%ebp)
801043b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043b8:	3b 45 10             	cmp    0x10(%ebp),%eax
801043bb:	0f 8c 51 ff ff ff    	jl     80104312 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801043c1:	8b 45 08             	mov    0x8(%ebp),%eax
801043c4:	05 34 02 00 00       	add    $0x234,%eax
801043c9:	89 04 24             	mov    %eax,(%esp)
801043cc:	e8 29 0c 00 00       	call   80104ffa <wakeup>
  release(&p->lock);
801043d1:	8b 45 08             	mov    0x8(%ebp),%eax
801043d4:	89 04 24             	mov    %eax,(%esp)
801043d7:	e8 01 13 00 00       	call   801056dd <release>
  return n;
801043dc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801043df:	c9                   	leave  
801043e0:	c3                   	ret    

801043e1 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801043e1:	55                   	push   %ebp
801043e2:	89 e5                	mov    %esp,%ebp
801043e4:	53                   	push   %ebx
801043e5:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801043e8:	8b 45 08             	mov    0x8(%ebp),%eax
801043eb:	89 04 24             	mov    %eax,(%esp)
801043ee:	e8 80 12 00 00       	call   80105673 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043f3:	eb 39                	jmp    8010442e <piperead+0x4d>
    if(myproc()->killed){
801043f5:	e8 d1 01 00 00       	call   801045cb <myproc>
801043fa:	8b 40 24             	mov    0x24(%eax),%eax
801043fd:	85 c0                	test   %eax,%eax
801043ff:	74 15                	je     80104416 <piperead+0x35>
      release(&p->lock);
80104401:	8b 45 08             	mov    0x8(%ebp),%eax
80104404:	89 04 24             	mov    %eax,(%esp)
80104407:	e8 d1 12 00 00       	call   801056dd <release>
      return -1;
8010440c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104411:	e9 b3 00 00 00       	jmp    801044c9 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104416:	8b 45 08             	mov    0x8(%ebp),%eax
80104419:	8b 55 08             	mov    0x8(%ebp),%edx
8010441c:	81 c2 34 02 00 00    	add    $0x234,%edx
80104422:	89 44 24 04          	mov    %eax,0x4(%esp)
80104426:	89 14 24             	mov    %edx,(%esp)
80104429:	e8 f5 0a 00 00       	call   80104f23 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010442e:	8b 45 08             	mov    0x8(%ebp),%eax
80104431:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104437:	8b 45 08             	mov    0x8(%ebp),%eax
8010443a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104440:	39 c2                	cmp    %eax,%edx
80104442:	75 0d                	jne    80104451 <piperead+0x70>
80104444:	8b 45 08             	mov    0x8(%ebp),%eax
80104447:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010444d:	85 c0                	test   %eax,%eax
8010444f:	75 a4                	jne    801043f5 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104451:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104458:	eb 49                	jmp    801044a3 <piperead+0xc2>
    if(p->nread == p->nwrite)
8010445a:	8b 45 08             	mov    0x8(%ebp),%eax
8010445d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104463:	8b 45 08             	mov    0x8(%ebp),%eax
80104466:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010446c:	39 c2                	cmp    %eax,%edx
8010446e:	75 02                	jne    80104472 <piperead+0x91>
      break;
80104470:	eb 39                	jmp    801044ab <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104472:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104475:	8b 45 0c             	mov    0xc(%ebp),%eax
80104478:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010447b:	8b 45 08             	mov    0x8(%ebp),%eax
8010447e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104484:	8d 48 01             	lea    0x1(%eax),%ecx
80104487:	8b 55 08             	mov    0x8(%ebp),%edx
8010448a:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104490:	25 ff 01 00 00       	and    $0x1ff,%eax
80104495:	89 c2                	mov    %eax,%edx
80104497:	8b 45 08             	mov    0x8(%ebp),%eax
8010449a:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
8010449e:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801044a0:	ff 45 f4             	incl   -0xc(%ebp)
801044a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801044a9:	7c af                	jl     8010445a <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801044ab:	8b 45 08             	mov    0x8(%ebp),%eax
801044ae:	05 38 02 00 00       	add    $0x238,%eax
801044b3:	89 04 24             	mov    %eax,(%esp)
801044b6:	e8 3f 0b 00 00       	call   80104ffa <wakeup>
  release(&p->lock);
801044bb:	8b 45 08             	mov    0x8(%ebp),%eax
801044be:	89 04 24             	mov    %eax,(%esp)
801044c1:	e8 17 12 00 00       	call   801056dd <release>
  return i;
801044c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044c9:	83 c4 24             	add    $0x24,%esp
801044cc:	5b                   	pop    %ebx
801044cd:	5d                   	pop    %ebp
801044ce:	c3                   	ret    
	...

801044d0 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801044d0:	55                   	push   %ebp
801044d1:	89 e5                	mov    %esp,%ebp
801044d3:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801044d6:	9c                   	pushf  
801044d7:	58                   	pop    %eax
801044d8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801044db:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801044de:	c9                   	leave  
801044df:	c3                   	ret    

801044e0 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801044e0:	55                   	push   %ebp
801044e1:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801044e3:	fb                   	sti    
}
801044e4:	5d                   	pop    %ebp
801044e5:	c3                   	ret    

801044e6 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801044e6:	55                   	push   %ebp
801044e7:	89 e5                	mov    %esp,%ebp
801044e9:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801044ec:	c7 44 24 04 a4 9e 10 	movl   $0x80109ea4,0x4(%esp)
801044f3:	80 
801044f4:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
801044fb:	e8 52 11 00 00       	call   80105652 <initlock>
}
80104500:	c9                   	leave  
80104501:	c3                   	ret    

80104502 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104502:	55                   	push   %ebp
80104503:	89 e5                	mov    %esp,%ebp
80104505:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104508:	e8 3a 00 00 00       	call   80104547 <mycpu>
8010450d:	89 c2                	mov    %eax,%edx
8010450f:	b8 e0 5c 11 80       	mov    $0x80115ce0,%eax
80104514:	29 c2                	sub    %eax,%edx
80104516:	89 d0                	mov    %edx,%eax
80104518:	c1 f8 04             	sar    $0x4,%eax
8010451b:	89 c1                	mov    %eax,%ecx
8010451d:	89 ca                	mov    %ecx,%edx
8010451f:	c1 e2 03             	shl    $0x3,%edx
80104522:	01 ca                	add    %ecx,%edx
80104524:	89 d0                	mov    %edx,%eax
80104526:	c1 e0 05             	shl    $0x5,%eax
80104529:	29 d0                	sub    %edx,%eax
8010452b:	c1 e0 02             	shl    $0x2,%eax
8010452e:	01 c8                	add    %ecx,%eax
80104530:	c1 e0 03             	shl    $0x3,%eax
80104533:	01 c8                	add    %ecx,%eax
80104535:	89 c2                	mov    %eax,%edx
80104537:	c1 e2 0f             	shl    $0xf,%edx
8010453a:	29 c2                	sub    %eax,%edx
8010453c:	c1 e2 02             	shl    $0x2,%edx
8010453f:	01 ca                	add    %ecx,%edx
80104541:	89 d0                	mov    %edx,%eax
80104543:	f7 d8                	neg    %eax
}
80104545:	c9                   	leave  
80104546:	c3                   	ret    

80104547 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104547:	55                   	push   %ebp
80104548:	89 e5                	mov    %esp,%ebp
8010454a:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
8010454d:	e8 7e ff ff ff       	call   801044d0 <readeflags>
80104552:	25 00 02 00 00       	and    $0x200,%eax
80104557:	85 c0                	test   %eax,%eax
80104559:	74 0c                	je     80104567 <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
8010455b:	c7 04 24 ac 9e 10 80 	movl   $0x80109eac,(%esp)
80104562:	e8 ed bf ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
80104567:	e8 15 ee ff ff       	call   80103381 <lapicid>
8010456c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010456f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104576:	eb 3b                	jmp    801045b3 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104578:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010457b:	89 d0                	mov    %edx,%eax
8010457d:	c1 e0 02             	shl    $0x2,%eax
80104580:	01 d0                	add    %edx,%eax
80104582:	01 c0                	add    %eax,%eax
80104584:	01 d0                	add    %edx,%eax
80104586:	c1 e0 04             	shl    $0x4,%eax
80104589:	05 e0 5c 11 80       	add    $0x80115ce0,%eax
8010458e:	8a 00                	mov    (%eax),%al
80104590:	0f b6 c0             	movzbl %al,%eax
80104593:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104596:	75 18                	jne    801045b0 <mycpu+0x69>
      return &cpus[i];
80104598:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010459b:	89 d0                	mov    %edx,%eax
8010459d:	c1 e0 02             	shl    $0x2,%eax
801045a0:	01 d0                	add    %edx,%eax
801045a2:	01 c0                	add    %eax,%eax
801045a4:	01 d0                	add    %edx,%eax
801045a6:	c1 e0 04             	shl    $0x4,%eax
801045a9:	05 e0 5c 11 80       	add    $0x80115ce0,%eax
801045ae:	eb 19                	jmp    801045c9 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801045b0:	ff 45 f4             	incl   -0xc(%ebp)
801045b3:	a1 60 62 11 80       	mov    0x80116260,%eax
801045b8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801045bb:	7c bb                	jl     80104578 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
801045bd:	c7 04 24 d2 9e 10 80 	movl   $0x80109ed2,(%esp)
801045c4:	e8 8b bf ff ff       	call   80100554 <panic>
}
801045c9:	c9                   	leave  
801045ca:	c3                   	ret    

801045cb <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801045cb:	55                   	push   %ebp
801045cc:	89 e5                	mov    %esp,%ebp
801045ce:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
801045d1:	e8 fc 11 00 00       	call   801057d2 <pushcli>
  c = mycpu();
801045d6:	e8 6c ff ff ff       	call   80104547 <mycpu>
801045db:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801045de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e1:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801045e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801045ea:	e8 2d 12 00 00       	call   8010581c <popcli>
  return p;
801045ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801045f2:	c9                   	leave  
801045f3:	c3                   	ret    

801045f4 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801045f4:	55                   	push   %ebp
801045f5:	89 e5                	mov    %esp,%ebp
801045f7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801045fa:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104601:	e8 6d 10 00 00       	call   80105673 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104606:	c7 45 f4 b4 62 11 80 	movl   $0x801162b4,-0xc(%ebp)
8010460d:	eb 53                	jmp    80104662 <allocproc+0x6e>
    if(p->state == UNUSED)
8010460f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104612:	8b 40 0c             	mov    0xc(%eax),%eax
80104615:	85 c0                	test   %eax,%eax
80104617:	75 42                	jne    8010465b <allocproc+0x67>
      goto found;
80104619:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010461a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461d:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104624:	a1 04 d0 10 80       	mov    0x8010d004,%eax
80104629:	8d 50 01             	lea    0x1(%eax),%edx
8010462c:	89 15 04 d0 10 80    	mov    %edx,0x8010d004
80104632:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104635:	89 42 10             	mov    %eax,0x10(%edx)


  release(&ptable.lock);
80104638:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
8010463f:	e8 99 10 00 00       	call   801056dd <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104644:	e8 ed e8 ff ff       	call   80102f36 <kalloc>
80104649:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010464c:	89 42 08             	mov    %eax,0x8(%edx)
8010464f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104652:	8b 40 08             	mov    0x8(%eax),%eax
80104655:	85 c0                	test   %eax,%eax
80104657:	75 39                	jne    80104692 <allocproc+0x9e>
80104659:	eb 26                	jmp    80104681 <allocproc+0x8d>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010465b:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104662:	81 7d f4 b4 84 11 80 	cmpl   $0x801184b4,-0xc(%ebp)
80104669:	72 a4                	jb     8010460f <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
8010466b:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104672:	e8 66 10 00 00       	call   801056dd <release>
  return 0;
80104677:	b8 00 00 00 00       	mov    $0x0,%eax
8010467c:	e9 8d 00 00 00       	jmp    8010470e <allocproc+0x11a>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104681:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104684:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010468b:	b8 00 00 00 00       	mov    $0x0,%eax
80104690:	eb 7c                	jmp    8010470e <allocproc+0x11a>
  }
  sp = p->kstack + KSTACKSIZE;
80104692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104695:	8b 40 08             	mov    0x8(%eax),%eax
80104698:	05 00 10 00 00       	add    $0x1000,%eax
8010469d:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801046a0:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801046a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046aa:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801046ad:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801046b1:	ba 1c 74 10 80       	mov    $0x8010741c,%edx
801046b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801046b9:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801046bb:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801046bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046c5:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801046c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046cb:	8b 40 1c             	mov    0x1c(%eax),%eax
801046ce:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801046d5:	00 
801046d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801046dd:	00 
801046de:	89 04 24             	mov    %eax,(%esp)
801046e1:	e8 f0 11 00 00       	call   801058d6 <memset>
  p->context->eip = (uint)forkret;
801046e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046e9:	8b 40 1c             	mov    0x1c(%eax),%eax
801046ec:	ba e4 4e 10 80       	mov    $0x80104ee4,%edx
801046f1:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
801046f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f7:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = NULL;
801046fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104701:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104708:	00 00 00 
  // p->usage = 0;
  return p;
8010470b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010470e:	c9                   	leave  
8010470f:	c3                   	ret    

80104710 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104710:	55                   	push   %ebp
80104711:	89 e5                	mov    %esp,%ebp
80104713:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104716:	e8 d9 fe ff ff       	call   801045f4 <allocproc>
8010471b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
8010471e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104721:	a3 20 d9 10 80       	mov    %eax,0x8010d920
  if((p->pgdir = setupkvm()) == 0)
80104726:	e8 4b 42 00 00       	call   80108976 <setupkvm>
8010472b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010472e:	89 42 04             	mov    %eax,0x4(%edx)
80104731:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104734:	8b 40 04             	mov    0x4(%eax),%eax
80104737:	85 c0                	test   %eax,%eax
80104739:	75 0c                	jne    80104747 <userinit+0x37>
    panic("userinit: out of memory?");
8010473b:	c7 04 24 e2 9e 10 80 	movl   $0x80109ee2,(%esp)
80104742:	e8 0d be ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104747:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010474c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010474f:	8b 40 04             	mov    0x4(%eax),%eax
80104752:	89 54 24 08          	mov    %edx,0x8(%esp)
80104756:	c7 44 24 04 60 d5 10 	movl   $0x8010d560,0x4(%esp)
8010475d:	80 
8010475e:	89 04 24             	mov    %eax,(%esp)
80104761:	e8 71 44 00 00       	call   80108bd7 <inituvm>
  p->sz = PGSIZE;
80104766:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104769:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010476f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104772:	8b 40 18             	mov    0x18(%eax),%eax
80104775:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010477c:	00 
8010477d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104784:	00 
80104785:	89 04 24             	mov    %eax,(%esp)
80104788:	e8 49 11 00 00       	call   801058d6 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010478d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104790:	8b 40 18             	mov    0x18(%eax),%eax
80104793:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104799:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479c:	8b 40 18             	mov    0x18(%eax),%eax
8010479f:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801047a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a8:	8b 50 18             	mov    0x18(%eax),%edx
801047ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ae:	8b 40 18             	mov    0x18(%eax),%eax
801047b1:	8b 40 2c             	mov    0x2c(%eax),%eax
801047b4:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
801047b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047bb:	8b 50 18             	mov    0x18(%eax),%edx
801047be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c1:	8b 40 18             	mov    0x18(%eax),%eax
801047c4:	8b 40 2c             	mov    0x2c(%eax),%eax
801047c7:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
801047cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ce:	8b 40 18             	mov    0x18(%eax),%eax
801047d1:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801047d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047db:	8b 40 18             	mov    0x18(%eax),%eax
801047de:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801047e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047e8:	8b 40 18             	mov    0x18(%eax),%eax
801047eb:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801047f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047f5:	83 c0 6c             	add    $0x6c,%eax
801047f8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801047ff:	00 
80104800:	c7 44 24 04 fb 9e 10 	movl   $0x80109efb,0x4(%esp)
80104807:	80 
80104808:	89 04 24             	mov    %eax,(%esp)
8010480b:	e8 d2 12 00 00       	call   80105ae2 <safestrcpy>
  p->cwd = namei("/");
80104810:	c7 04 24 04 9f 10 80 	movl   $0x80109f04,(%esp)
80104817:	e8 ac df ff ff       	call   801027c8 <namei>
8010481c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010481f:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80104822:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104829:	e8 45 0e 00 00       	call   80105673 <acquire>

  p->state = RUNNABLE;
8010482e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104831:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80104838:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
8010483f:	e8 99 0e 00 00       	call   801056dd <release>
}
80104844:	c9                   	leave  
80104845:	c3                   	ret    

80104846 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80104846:	55                   	push   %ebp
80104847:	89 e5                	mov    %esp,%ebp
80104849:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
8010484c:	e8 7a fd ff ff       	call   801045cb <myproc>
80104851:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104854:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104857:	8b 00                	mov    (%eax),%eax
80104859:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010485c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104860:	7e 31                	jle    80104893 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104862:	8b 55 08             	mov    0x8(%ebp),%edx
80104865:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104868:	01 c2                	add    %eax,%edx
8010486a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010486d:	8b 40 04             	mov    0x4(%eax),%eax
80104870:	89 54 24 08          	mov    %edx,0x8(%esp)
80104874:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104877:	89 54 24 04          	mov    %edx,0x4(%esp)
8010487b:	89 04 24             	mov    %eax,(%esp)
8010487e:	e8 bf 44 00 00       	call   80108d42 <allocuvm>
80104883:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104886:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010488a:	75 3e                	jne    801048ca <growproc+0x84>
      return -1;
8010488c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104891:	eb 4f                	jmp    801048e2 <growproc+0x9c>
  } else if(n < 0){
80104893:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104897:	79 31                	jns    801048ca <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104899:	8b 55 08             	mov    0x8(%ebp),%edx
8010489c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010489f:	01 c2                	add    %eax,%edx
801048a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048a4:	8b 40 04             	mov    0x4(%eax),%eax
801048a7:	89 54 24 08          	mov    %edx,0x8(%esp)
801048ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048ae:	89 54 24 04          	mov    %edx,0x4(%esp)
801048b2:	89 04 24             	mov    %eax,(%esp)
801048b5:	e8 9e 45 00 00       	call   80108e58 <deallocuvm>
801048ba:	89 45 f4             	mov    %eax,-0xc(%ebp)
801048bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048c1:	75 07                	jne    801048ca <growproc+0x84>
      return -1;
801048c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048c8:	eb 18                	jmp    801048e2 <growproc+0x9c>
  }
  curproc->sz = sz;
801048ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048d0:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801048d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048d5:	89 04 24             	mov    %eax,(%esp)
801048d8:	e8 73 41 00 00       	call   80108a50 <switchuvm>
  return 0;
801048dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048e2:	c9                   	leave  
801048e3:	c3                   	ret    

801048e4 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801048e4:	55                   	push   %ebp
801048e5:	89 e5                	mov    %esp,%ebp
801048e7:	57                   	push   %edi
801048e8:	56                   	push   %esi
801048e9:	53                   	push   %ebx
801048ea:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801048ed:	e8 d9 fc ff ff       	call   801045cb <myproc>
801048f2:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
801048f5:	e8 fa fc ff ff       	call   801045f4 <allocproc>
801048fa:	89 45 dc             	mov    %eax,-0x24(%ebp)
801048fd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104901:	75 0a                	jne    8010490d <fork+0x29>
    return -1;
80104903:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104908:	e9 47 01 00 00       	jmp    80104a54 <fork+0x170>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010490d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104910:	8b 10                	mov    (%eax),%edx
80104912:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104915:	8b 40 04             	mov    0x4(%eax),%eax
80104918:	89 54 24 04          	mov    %edx,0x4(%esp)
8010491c:	89 04 24             	mov    %eax,(%esp)
8010491f:	e8 d4 46 00 00       	call   80108ff8 <copyuvm>
80104924:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104927:	89 42 04             	mov    %eax,0x4(%edx)
8010492a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010492d:	8b 40 04             	mov    0x4(%eax),%eax
80104930:	85 c0                	test   %eax,%eax
80104932:	75 2c                	jne    80104960 <fork+0x7c>
    kfree(np->kstack);
80104934:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104937:	8b 40 08             	mov    0x8(%eax),%eax
8010493a:	89 04 24             	mov    %eax,(%esp)
8010493d:	e8 05 e5 ff ff       	call   80102e47 <kfree>
    np->kstack = 0;
80104942:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104945:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010494c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010494f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104956:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010495b:	e9 f4 00 00 00       	jmp    80104a54 <fork+0x170>
  }
  np->sz = curproc->sz;
80104960:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104963:	8b 10                	mov    (%eax),%edx
80104965:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104968:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010496a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010496d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104970:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104973:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104976:	8b 50 18             	mov    0x18(%eax),%edx
80104979:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010497c:	8b 40 18             	mov    0x18(%eax),%eax
8010497f:	89 c3                	mov    %eax,%ebx
80104981:	b8 13 00 00 00       	mov    $0x13,%eax
80104986:	89 d7                	mov    %edx,%edi
80104988:	89 de                	mov    %ebx,%esi
8010498a:	89 c1                	mov    %eax,%ecx
8010498c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010498e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104991:	8b 40 18             	mov    0x18(%eax),%eax
80104994:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010499b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801049a2:	eb 36                	jmp    801049da <fork+0xf6>
    if(curproc->ofile[i])
801049a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049aa:	83 c2 08             	add    $0x8,%edx
801049ad:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049b1:	85 c0                	test   %eax,%eax
801049b3:	74 22                	je     801049d7 <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
801049b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049b8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801049bb:	83 c2 08             	add    $0x8,%edx
801049be:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049c2:	89 04 24             	mov    %eax,(%esp)
801049c5:	e8 98 c7 ff ff       	call   80101162 <filedup>
801049ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
801049cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801049d0:	83 c1 08             	add    $0x8,%ecx
801049d3:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801049d7:	ff 45 e4             	incl   -0x1c(%ebp)
801049da:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801049de:	7e c4                	jle    801049a4 <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801049e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049e3:	8b 40 68             	mov    0x68(%eax),%eax
801049e6:	89 04 24             	mov    %eax,(%esp)
801049e9:	e8 07 d1 ff ff       	call   80101af5 <idup>
801049ee:	8b 55 dc             	mov    -0x24(%ebp),%edx
801049f1:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801049f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801049f7:	8d 50 6c             	lea    0x6c(%eax),%edx
801049fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801049fd:	83 c0 6c             	add    $0x6c,%eax
80104a00:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104a07:	00 
80104a08:	89 54 24 04          	mov    %edx,0x4(%esp)
80104a0c:	89 04 24             	mov    %eax,(%esp)
80104a0f:	e8 ce 10 00 00       	call   80105ae2 <safestrcpy>



  pid = np->pid;
80104a14:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a17:	8b 40 10             	mov    0x10(%eax),%eax
80104a1a:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104a1d:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104a24:	e8 4a 0c 00 00       	call   80105673 <acquire>

  np->state = RUNNABLE;
80104a29:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a2c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  np->cont = curproc->cont;
80104a33:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a36:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104a3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104a3f:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  //   cprintf("curproc container name is %s.\n", curproc->cont->name);
  //   cprintf("new proc container name is %s.\n", np->cont->name);

  // }

  release(&ptable.lock);
80104a45:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104a4c:	e8 8c 0c 00 00       	call   801056dd <release>

  return pid;
80104a51:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104a54:	83 c4 2c             	add    $0x2c,%esp
80104a57:	5b                   	pop    %ebx
80104a58:	5e                   	pop    %esi
80104a59:	5f                   	pop    %edi
80104a5a:	5d                   	pop    %ebp
80104a5b:	c3                   	ret    

80104a5c <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104a5c:	55                   	push   %ebp
80104a5d:	89 e5                	mov    %esp,%ebp
80104a5f:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
80104a62:	e8 64 fb ff ff       	call   801045cb <myproc>
80104a67:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80104a6a:	a1 20 d9 10 80       	mov    0x8010d920,%eax
80104a6f:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104a72:	75 0c                	jne    80104a80 <exit+0x24>
    panic("init exiting");
80104a74:	c7 04 24 06 9f 10 80 	movl   $0x80109f06,(%esp)
80104a7b:	e8 d4 ba ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a80:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104a87:	eb 3a                	jmp    80104ac3 <exit+0x67>
    if(curproc->ofile[fd]){
80104a89:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a8f:	83 c2 08             	add    $0x8,%edx
80104a92:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104a96:	85 c0                	test   %eax,%eax
80104a98:	74 26                	je     80104ac0 <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104a9a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a9d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104aa0:	83 c2 08             	add    $0x8,%edx
80104aa3:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104aa7:	89 04 24             	mov    %eax,(%esp)
80104aaa:	e8 fb c6 ff ff       	call   801011aa <fileclose>
      curproc->ofile[fd] = 0;
80104aaf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ab2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ab5:	83 c2 08             	add    $0x8,%edx
80104ab8:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104abf:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104ac0:	ff 45 f0             	incl   -0x10(%ebp)
80104ac3:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104ac7:	7e c0                	jle    80104a89 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104ac9:	e8 fd ed ff ff       	call   801038cb <begin_op>
  iput(curproc->cwd);
80104ace:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ad1:	8b 40 68             	mov    0x68(%eax),%eax
80104ad4:	89 04 24             	mov    %eax,(%esp)
80104ad7:	e8 99 d1 ff ff       	call   80101c75 <iput>
  end_op();
80104adc:	e8 6c ee ff ff       	call   8010394d <end_op>
  curproc->cwd = 0;
80104ae1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ae4:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104aeb:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104af2:	e8 7c 0b 00 00       	call   80105673 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104af7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104afa:	8b 40 14             	mov    0x14(%eax),%eax
80104afd:	89 04 24             	mov    %eax,(%esp)
80104b00:	e8 b4 04 00 00       	call   80104fb9 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b05:	c7 45 f4 b4 62 11 80 	movl   $0x801162b4,-0xc(%ebp)
80104b0c:	eb 36                	jmp    80104b44 <exit+0xe8>
    if(p->parent == curproc){
80104b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b11:	8b 40 14             	mov    0x14(%eax),%eax
80104b14:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104b17:	75 24                	jne    80104b3d <exit+0xe1>
      p->parent = initproc;
80104b19:	8b 15 20 d9 10 80    	mov    0x8010d920,%edx
80104b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b22:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b28:	8b 40 0c             	mov    0xc(%eax),%eax
80104b2b:	83 f8 05             	cmp    $0x5,%eax
80104b2e:	75 0d                	jne    80104b3d <exit+0xe1>
        wakeup1(initproc);
80104b30:	a1 20 d9 10 80       	mov    0x8010d920,%eax
80104b35:	89 04 24             	mov    %eax,(%esp)
80104b38:	e8 7c 04 00 00       	call   80104fb9 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b3d:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104b44:	81 7d f4 b4 84 11 80 	cmpl   $0x801184b4,-0xc(%ebp)
80104b4b:	72 c1                	jb     80104b0e <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104b4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b50:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104b57:	e8 a8 02 00 00       	call   80104e04 <sched>
  panic("zombie exit");
80104b5c:	c7 04 24 13 9f 10 80 	movl   $0x80109f13,(%esp)
80104b63:	e8 ec b9 ff ff       	call   80100554 <panic>

80104b68 <strcmp1>:
}


int
strcmp1(const char *p, const char *q)
{
80104b68:	55                   	push   %ebp
80104b69:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80104b6b:	eb 06                	jmp    80104b73 <strcmp1+0xb>
    p++, q++;
80104b6d:	ff 45 08             	incl   0x8(%ebp)
80104b70:	ff 45 0c             	incl   0xc(%ebp)


int
strcmp1(const char *p, const char *q)
{
  while(*p && *p == *q)
80104b73:	8b 45 08             	mov    0x8(%ebp),%eax
80104b76:	8a 00                	mov    (%eax),%al
80104b78:	84 c0                	test   %al,%al
80104b7a:	74 0e                	je     80104b8a <strcmp1+0x22>
80104b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80104b7f:	8a 10                	mov    (%eax),%dl
80104b81:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b84:	8a 00                	mov    (%eax),%al
80104b86:	38 c2                	cmp    %al,%dl
80104b88:	74 e3                	je     80104b6d <strcmp1+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80104b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b8d:	8a 00                	mov    (%eax),%al
80104b8f:	0f b6 d0             	movzbl %al,%edx
80104b92:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b95:	8a 00                	mov    (%eax),%al
80104b97:	0f b6 c0             	movzbl %al,%eax
80104b9a:	29 c2                	sub    %eax,%edx
80104b9c:	89 d0                	mov    %edx,%eax
}
80104b9e:	5d                   	pop    %ebp
80104b9f:	c3                   	ret    

80104ba0 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104ba0:	55                   	push   %ebp
80104ba1:	89 e5                	mov    %esp,%ebp
80104ba3:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80104ba6:	e8 20 fa ff ff       	call   801045cb <myproc>
80104bab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80104bae:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104bb5:	e8 b9 0a 00 00       	call   80105673 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104bba:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bc1:	c7 45 f4 b4 62 11 80 	movl   $0x801162b4,-0xc(%ebp)
80104bc8:	e9 98 00 00 00       	jmp    80104c65 <wait+0xc5>
      if(p->parent != curproc)
80104bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd0:	8b 40 14             	mov    0x14(%eax),%eax
80104bd3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104bd6:	74 05                	je     80104bdd <wait+0x3d>
        continue;
80104bd8:	e9 81 00 00 00       	jmp    80104c5e <wait+0xbe>
      havekids = 1;
80104bdd:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be7:	8b 40 0c             	mov    0xc(%eax),%eax
80104bea:	83 f8 05             	cmp    $0x5,%eax
80104bed:	75 6f                	jne    80104c5e <wait+0xbe>
        // Found one.
        pid = p->pid;
80104bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf2:	8b 40 10             	mov    0x10(%eax),%eax
80104bf5:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bfb:	8b 40 08             	mov    0x8(%eax),%eax
80104bfe:	89 04 24             	mov    %eax,(%esp)
80104c01:	e8 41 e2 ff ff       	call   80102e47 <kfree>
        p->kstack = 0;
80104c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c09:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c13:	8b 40 04             	mov    0x4(%eax),%eax
80104c16:	89 04 24             	mov    %eax,(%esp)
80104c19:	e8 fe 42 00 00       	call   80108f1c <freevm>
        p->pid = 0;
80104c1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c21:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c35:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3c:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c46:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
80104c4d:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104c54:	e8 84 0a 00 00       	call   801056dd <release>
        return pid;
80104c59:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104c5c:	eb 4f                	jmp    80104cad <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c5e:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104c65:	81 7d f4 b4 84 11 80 	cmpl   $0x801184b4,-0xc(%ebp)
80104c6c:	0f 82 5b ff ff ff    	jb     80104bcd <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104c72:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c76:	74 0a                	je     80104c82 <wait+0xe2>
80104c78:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c7b:	8b 40 24             	mov    0x24(%eax),%eax
80104c7e:	85 c0                	test   %eax,%eax
80104c80:	74 13                	je     80104c95 <wait+0xf5>
      release(&ptable.lock);
80104c82:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104c89:	e8 4f 0a 00 00       	call   801056dd <release>
      return -1;
80104c8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c93:	eb 18                	jmp    80104cad <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104c95:	c7 44 24 04 80 62 11 	movl   $0x80116280,0x4(%esp)
80104c9c:	80 
80104c9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ca0:	89 04 24             	mov    %eax,(%esp)
80104ca3:	e8 7b 02 00 00       	call   80104f23 <sleep>
  }
80104ca8:	e9 0d ff ff ff       	jmp    80104bba <wait+0x1a>
}
80104cad:	c9                   	leave  
80104cae:	c3                   	ret    

80104caf <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104caf:	55                   	push   %ebp
80104cb0:	89 e5                	mov    %esp,%ebp
80104cb2:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct cpu *c = mycpu();
80104cb5:	e8 8d f8 ff ff       	call   80104547 <mycpu>
80104cba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cc0:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104cc7:	00 00 00 
  char name[16];
  
  for(;;){
    int x = get_used();
80104cca:	e8 76 46 00 00       	call   80109345 <get_used>
80104ccf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(holder >= x){
80104cd2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104cd7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104cda:	7c 0a                	jl     80104ce6 <scheduler+0x37>
      holder = -1;
80104cdc:	c7 05 00 d0 10 80 ff 	movl   $0xffffffff,0x8010d000
80104ce3:	ff ff ff 
    }
    if(holder != -1){
80104ce6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104ceb:	83 f8 ff             	cmp    $0xffffffff,%eax
80104cee:	74 14                	je     80104d04 <scheduler+0x55>
      get_name(holder, &name[0]);
80104cf0:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104cf5:	8d 55 dc             	lea    -0x24(%ebp),%edx
80104cf8:	89 54 24 04          	mov    %edx,0x4(%esp)
80104cfc:	89 04 24             	mov    %eax,(%esp)
80104cff:	e8 d8 45 00 00       	call   801092dc <get_name>
    }
    sti();
80104d04:	e8 d7 f7 ff ff       	call   801044e0 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104d09:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104d10:	e8 5e 09 00 00       	call   80105673 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d15:	c7 45 f4 b4 62 11 80 	movl   $0x801162b4,-0xc(%ebp)
80104d1c:	e9 ab 00 00 00       	jmp    80104dcc <scheduler+0x11d>
      if(p->state != RUNNABLE)
80104d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d24:	8b 40 0c             	mov    0xc(%eax),%eax
80104d27:	83 f8 03             	cmp    $0x3,%eax
80104d2a:	74 05                	je     80104d31 <scheduler+0x82>
        continue;
80104d2c:	e9 94 00 00 00       	jmp    80104dc5 <scheduler+0x116>
      if(holder == -1){
80104d31:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104d36:	83 f8 ff             	cmp    $0xffffffff,%eax
80104d39:	75 0f                	jne    80104d4a <scheduler+0x9b>
        if(p->cont != NULL){
80104d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d3e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104d44:	85 c0                	test   %eax,%eax
80104d46:	74 32                	je     80104d7a <scheduler+0xcb>
          continue;
80104d48:	eb 7b                	jmp    80104dc5 <scheduler+0x116>
        }
      }
      else{
        if(p->cont == NULL){
80104d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d4d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104d53:	85 c0                	test   %eax,%eax
80104d55:	75 02                	jne    80104d59 <scheduler+0xaa>
          continue;
80104d57:	eb 6c                	jmp    80104dc5 <scheduler+0x116>
        }
        if(strcmp1(p->cont->name, name) != 0){
80104d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104d62:	8d 50 18             	lea    0x18(%eax),%edx
80104d65:	8d 45 dc             	lea    -0x24(%ebp),%eax
80104d68:	89 44 24 04          	mov    %eax,0x4(%esp)
80104d6c:	89 14 24             	mov    %edx,(%esp)
80104d6f:	e8 f4 fd ff ff       	call   80104b68 <strcmp1>
80104d74:	85 c0                	test   %eax,%eax
80104d76:	74 02                	je     80104d7a <scheduler+0xcb>
          continue;
80104d78:	eb 4b                	jmp    80104dc5 <scheduler+0x116>
      }

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104d7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d80:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d89:	89 04 24             	mov    %eax,(%esp)
80104d8c:	e8 bf 3c 00 00       	call   80108a50 <switchuvm>
      p->state = RUNNING;
80104d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d94:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d9e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104da1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104da4:	83 c2 04             	add    $0x4,%edx
80104da7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dab:	89 14 24             	mov    %edx,(%esp)
80104dae:	e8 9d 0d 00 00       	call   80105b50 <swtch>
      switchkvm();
80104db3:	e8 7e 3c 00 00       	call   80108a36 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104db8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dbb:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104dc2:	00 00 00 
    }
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104dc5:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80104dcc:	81 7d f4 b4 84 11 80 	cmpl   $0x801184b4,-0xc(%ebp)
80104dd3:	0f 82 48 ff ff ff    	jb     80104d21 <scheduler+0x72>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
80104dd9:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104de0:	e8 f8 08 00 00       	call   801056dd <release>
    p->ticks++;
80104de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104de8:	8b 40 7c             	mov    0x7c(%eax),%eax
80104deb:	8d 50 01             	lea    0x1(%eax),%edx
80104dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df1:	89 50 7c             	mov    %edx,0x7c(%eax)
    holder++;
80104df4:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80104df9:	40                   	inc    %eax
80104dfa:	a3 00 d0 10 80       	mov    %eax,0x8010d000

  }
80104dff:	e9 c6 fe ff ff       	jmp    80104cca <scheduler+0x1b>

80104e04 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104e04:	55                   	push   %ebp
80104e05:	89 e5                	mov    %esp,%ebp
80104e07:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104e0a:	e8 bc f7 ff ff       	call   801045cb <myproc>
80104e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104e12:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104e19:	e8 83 09 00 00       	call   801057a1 <holding>
80104e1e:	85 c0                	test   %eax,%eax
80104e20:	75 0c                	jne    80104e2e <sched+0x2a>
    panic("sched ptable.lock");
80104e22:	c7 04 24 1f 9f 10 80 	movl   $0x80109f1f,(%esp)
80104e29:	e8 26 b7 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104e2e:	e8 14 f7 ff ff       	call   80104547 <mycpu>
80104e33:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104e39:	83 f8 01             	cmp    $0x1,%eax
80104e3c:	74 0c                	je     80104e4a <sched+0x46>
    panic("sched locks");
80104e3e:	c7 04 24 31 9f 10 80 	movl   $0x80109f31,(%esp)
80104e45:	e8 0a b7 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4d:	8b 40 0c             	mov    0xc(%eax),%eax
80104e50:	83 f8 04             	cmp    $0x4,%eax
80104e53:	75 0c                	jne    80104e61 <sched+0x5d>
    panic("sched running");
80104e55:	c7 04 24 3d 9f 10 80 	movl   $0x80109f3d,(%esp)
80104e5c:	e8 f3 b6 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104e61:	e8 6a f6 ff ff       	call   801044d0 <readeflags>
80104e66:	25 00 02 00 00       	and    $0x200,%eax
80104e6b:	85 c0                	test   %eax,%eax
80104e6d:	74 0c                	je     80104e7b <sched+0x77>
    panic("sched interruptible");
80104e6f:	c7 04 24 4b 9f 10 80 	movl   $0x80109f4b,(%esp)
80104e76:	e8 d9 b6 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104e7b:	e8 c7 f6 ff ff       	call   80104547 <mycpu>
80104e80:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104e86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104e89:	e8 b9 f6 ff ff       	call   80104547 <mycpu>
80104e8e:	8b 40 04             	mov    0x4(%eax),%eax
80104e91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e94:	83 c2 1c             	add    $0x1c,%edx
80104e97:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e9b:	89 14 24             	mov    %edx,(%esp)
80104e9e:	e8 ad 0c 00 00       	call   80105b50 <swtch>
  mycpu()->intena = intena;
80104ea3:	e8 9f f6 ff ff       	call   80104547 <mycpu>
80104ea8:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104eab:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104eb1:	c9                   	leave  
80104eb2:	c3                   	ret    

80104eb3 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104eb3:	55                   	push   %ebp
80104eb4:	89 e5                	mov    %esp,%ebp
80104eb6:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104eb9:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104ec0:	e8 ae 07 00 00       	call   80105673 <acquire>
  myproc()->state = RUNNABLE;
80104ec5:	e8 01 f7 ff ff       	call   801045cb <myproc>
80104eca:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104ed1:	e8 2e ff ff ff       	call   80104e04 <sched>
  release(&ptable.lock);
80104ed6:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104edd:	e8 fb 07 00 00       	call   801056dd <release>
}
80104ee2:	c9                   	leave  
80104ee3:	c3                   	ret    

80104ee4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104ee4:	55                   	push   %ebp
80104ee5:	89 e5                	mov    %esp,%ebp
80104ee7:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104eea:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104ef1:	e8 e7 07 00 00       	call   801056dd <release>

  if (first) {
80104ef6:	a1 08 d0 10 80       	mov    0x8010d008,%eax
80104efb:	85 c0                	test   %eax,%eax
80104efd:	74 22                	je     80104f21 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104eff:	c7 05 08 d0 10 80 00 	movl   $0x0,0x8010d008
80104f06:	00 00 00 
    iinit(ROOTDEV);
80104f09:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104f10:	e8 46 c8 ff ff       	call   8010175b <iinit>
    initlog(ROOTDEV);
80104f15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104f1c:	e8 ab e7 ff ff       	call   801036cc <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104f21:	c9                   	leave  
80104f22:	c3                   	ret    

80104f23 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104f23:	55                   	push   %ebp
80104f24:	89 e5                	mov    %esp,%ebp
80104f26:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104f29:	e8 9d f6 ff ff       	call   801045cb <myproc>
80104f2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104f31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104f35:	75 0c                	jne    80104f43 <sleep+0x20>
    panic("sleep");
80104f37:	c7 04 24 5f 9f 10 80 	movl   $0x80109f5f,(%esp)
80104f3e:	e8 11 b6 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104f43:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104f47:	75 0c                	jne    80104f55 <sleep+0x32>
    panic("sleep without lk");
80104f49:	c7 04 24 65 9f 10 80 	movl   $0x80109f65,(%esp)
80104f50:	e8 ff b5 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104f55:	81 7d 0c 80 62 11 80 	cmpl   $0x80116280,0xc(%ebp)
80104f5c:	74 17                	je     80104f75 <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104f5e:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104f65:	e8 09 07 00 00       	call   80105673 <acquire>
    release(lk);
80104f6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f6d:	89 04 24             	mov    %eax,(%esp)
80104f70:	e8 68 07 00 00       	call   801056dd <release>
  }
  // Go to sleep.
  p->chan = chan;
80104f75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f78:	8b 55 08             	mov    0x8(%ebp),%edx
80104f7b:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f81:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104f88:	e8 77 fe ff ff       	call   80104e04 <sched>

  // Tidy up.
  p->chan = 0;
80104f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f90:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104f97:	81 7d 0c 80 62 11 80 	cmpl   $0x80116280,0xc(%ebp)
80104f9e:	74 17                	je     80104fb7 <sleep+0x94>
    release(&ptable.lock);
80104fa0:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80104fa7:	e8 31 07 00 00       	call   801056dd <release>
    acquire(lk);
80104fac:	8b 45 0c             	mov    0xc(%ebp),%eax
80104faf:	89 04 24             	mov    %eax,(%esp)
80104fb2:	e8 bc 06 00 00       	call   80105673 <acquire>
  }
}
80104fb7:	c9                   	leave  
80104fb8:	c3                   	ret    

80104fb9 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104fb9:	55                   	push   %ebp
80104fba:	89 e5                	mov    %esp,%ebp
80104fbc:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fbf:	c7 45 fc b4 62 11 80 	movl   $0x801162b4,-0x4(%ebp)
80104fc6:	eb 27                	jmp    80104fef <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104fc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fcb:	8b 40 0c             	mov    0xc(%eax),%eax
80104fce:	83 f8 02             	cmp    $0x2,%eax
80104fd1:	75 15                	jne    80104fe8 <wakeup1+0x2f>
80104fd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fd6:	8b 40 20             	mov    0x20(%eax),%eax
80104fd9:	3b 45 08             	cmp    0x8(%ebp),%eax
80104fdc:	75 0a                	jne    80104fe8 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104fde:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104fe1:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104fe8:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
80104fef:	81 7d fc b4 84 11 80 	cmpl   $0x801184b4,-0x4(%ebp)
80104ff6:	72 d0                	jb     80104fc8 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104ff8:	c9                   	leave  
80104ff9:	c3                   	ret    

80104ffa <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104ffa:	55                   	push   %ebp
80104ffb:	89 e5                	mov    %esp,%ebp
80104ffd:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80105000:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80105007:	e8 67 06 00 00       	call   80105673 <acquire>
  wakeup1(chan);
8010500c:	8b 45 08             	mov    0x8(%ebp),%eax
8010500f:	89 04 24             	mov    %eax,(%esp)
80105012:	e8 a2 ff ff ff       	call   80104fb9 <wakeup1>
  release(&ptable.lock);
80105017:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
8010501e:	e8 ba 06 00 00       	call   801056dd <release>
}
80105023:	c9                   	leave  
80105024:	c3                   	ret    

80105025 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80105025:	55                   	push   %ebp
80105026:	89 e5                	mov    %esp,%ebp
80105028:	53                   	push   %ebx
80105029:	83 ec 24             	sub    $0x24,%esp
  struct proc *p;
  
  acquire(&ptable.lock);
8010502c:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
80105033:	e8 3b 06 00 00       	call   80105673 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105038:	c7 45 f4 b4 62 11 80 	movl   $0x801162b4,-0xc(%ebp)
8010503f:	e9 9c 00 00 00       	jmp    801050e0 <kill+0xbb>
    if(p->pid == pid){
80105044:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105047:	8b 40 10             	mov    0x10(%eax),%eax
8010504a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010504d:	0f 85 86 00 00 00    	jne    801050d9 <kill+0xb4>
      if(myproc()->cont != NULL){
80105053:	e8 73 f5 ff ff       	call   801045cb <myproc>
80105058:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010505e:	85 c0                	test   %eax,%eax
80105060:	74 45                	je     801050a7 <kill+0x82>
        if(p->cont == NULL || strcmp1(myproc()->cont->name, p->cont->name) != 0 ){
80105062:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105065:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010506b:	85 c0                	test   %eax,%eax
8010506d:	74 2a                	je     80105099 <kill+0x74>
8010506f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105072:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105078:	8d 58 18             	lea    0x18(%eax),%ebx
8010507b:	e8 4b f5 ff ff       	call   801045cb <myproc>
80105080:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105086:	83 c0 18             	add    $0x18,%eax
80105089:	89 5c 24 04          	mov    %ebx,0x4(%esp)
8010508d:	89 04 24             	mov    %eax,(%esp)
80105090:	e8 d3 fa ff ff       	call   80104b68 <strcmp1>
80105095:	85 c0                	test   %eax,%eax
80105097:	74 0e                	je     801050a7 <kill+0x82>
          cprintf(" el oh el You are not authorized to do this.\n");
80105099:	c7 04 24 78 9f 10 80 	movl   $0x80109f78,(%esp)
801050a0:	e8 1c b3 ff ff       	call   801003c1 <cprintf>
          break;
801050a5:	eb 46                	jmp    801050ed <kill+0xc8>
        }
      }
      p->killed = 1;
801050a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050aa:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801050b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050b4:	8b 40 0c             	mov    0xc(%eax),%eax
801050b7:	83 f8 02             	cmp    $0x2,%eax
801050ba:	75 0a                	jne    801050c6 <kill+0xa1>
        p->state = RUNNABLE;
801050bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050bf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
801050c6:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
801050cd:	e8 0b 06 00 00       	call   801056dd <release>
      return 0;
801050d2:	b8 00 00 00 00       	mov    $0x0,%eax
801050d7:	eb 25                	jmp    801050fe <kill+0xd9>
kill(int pid)
{
  struct proc *p;
  
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801050d9:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801050e0:	81 7d f4 b4 84 11 80 	cmpl   $0x801184b4,-0xc(%ebp)
801050e7:	0f 82 57 ff ff ff    	jb     80105044 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801050ed:	c7 04 24 80 62 11 80 	movl   $0x80116280,(%esp)
801050f4:	e8 e4 05 00 00       	call   801056dd <release>
  return -1;
801050f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801050fe:	83 c4 24             	add    $0x24,%esp
80105101:	5b                   	pop    %ebx
80105102:	5d                   	pop    %ebp
80105103:	c3                   	ret    

80105104 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105104:	55                   	push   %ebp
80105105:	89 e5                	mov    %esp,%ebp
80105107:	53                   	push   %ebx
80105108:	83 ec 64             	sub    $0x64,%esp
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010510b:	c7 45 f0 b4 62 11 80 	movl   $0x801162b4,-0x10(%ebp)
80105112:	e9 32 01 00 00       	jmp    80105249 <procdump+0x145>
    if(p->state == UNUSED)
80105117:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010511a:	8b 40 0c             	mov    0xc(%eax),%eax
8010511d:	85 c0                	test   %eax,%eax
8010511f:	75 05                	jne    80105126 <procdump+0x22>
      continue;
80105121:	e9 1c 01 00 00       	jmp    80105242 <procdump+0x13e>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105126:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105129:	8b 40 0c             	mov    0xc(%eax),%eax
8010512c:	83 f8 05             	cmp    $0x5,%eax
8010512f:	77 23                	ja     80105154 <procdump+0x50>
80105131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105134:	8b 40 0c             	mov    0xc(%eax),%eax
80105137:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
8010513e:	85 c0                	test   %eax,%eax
80105140:	74 12                	je     80105154 <procdump+0x50>
      state = states[p->state];
80105142:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105145:	8b 40 0c             	mov    0xc(%eax),%eax
80105148:	8b 04 85 0c d0 10 80 	mov    -0x7fef2ff4(,%eax,4),%eax
8010514f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105152:	eb 07                	jmp    8010515b <procdump+0x57>
    else
      state = "???";
80105154:	c7 45 ec a6 9f 10 80 	movl   $0x80109fa6,-0x14(%ebp)

    if(p->cont == NULL){
8010515b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010515e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105164:	85 c0                	test   %eax,%eax
80105166:	75 33                	jne    8010519b <procdump+0x97>
      cprintf("%d root %s %s TICKS: %d", p->pid, state, p->name, p->ticks);
80105168:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010516b:	8b 50 7c             	mov    0x7c(%eax),%edx
8010516e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105171:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105174:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105177:	8b 40 10             	mov    0x10(%eax),%eax
8010517a:	89 54 24 10          	mov    %edx,0x10(%esp)
8010517e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80105182:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105185:	89 54 24 08          	mov    %edx,0x8(%esp)
80105189:	89 44 24 04          	mov    %eax,0x4(%esp)
8010518d:	c7 04 24 aa 9f 10 80 	movl   $0x80109faa,(%esp)
80105194:	e8 28 b2 ff ff       	call   801003c1 <cprintf>
80105199:	eb 41                	jmp    801051dc <procdump+0xd8>
    }
    else{
      cprintf("%d %s %s %s TICKS: %d", p->pid, p->cont->name, state, p->name, p->ticks);
8010519b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010519e:	8b 50 7c             	mov    0x7c(%eax),%edx
801051a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051a4:	8d 58 6c             	lea    0x6c(%eax),%ebx
801051a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051aa:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801051b0:	8d 48 18             	lea    0x18(%eax),%ecx
801051b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051b6:	8b 40 10             	mov    0x10(%eax),%eax
801051b9:	89 54 24 14          	mov    %edx,0x14(%esp)
801051bd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801051c1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051c4:	89 54 24 0c          	mov    %edx,0xc(%esp)
801051c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801051cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801051d0:	c7 04 24 c2 9f 10 80 	movl   $0x80109fc2,(%esp)
801051d7:	e8 e5 b1 ff ff       	call   801003c1 <cprintf>
    }
    if(p->state == SLEEPING){
801051dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051df:	8b 40 0c             	mov    0xc(%eax),%eax
801051e2:	83 f8 02             	cmp    $0x2,%eax
801051e5:	75 4f                	jne    80105236 <procdump+0x132>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801051e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ea:	8b 40 1c             	mov    0x1c(%eax),%eax
801051ed:	8b 40 0c             	mov    0xc(%eax),%eax
801051f0:	83 c0 08             	add    $0x8,%eax
801051f3:	8d 55 c4             	lea    -0x3c(%ebp),%edx
801051f6:	89 54 24 04          	mov    %edx,0x4(%esp)
801051fa:	89 04 24             	mov    %eax,(%esp)
801051fd:	e8 28 05 00 00       	call   8010572a <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80105202:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105209:	eb 1a                	jmp    80105225 <procdump+0x121>
        cprintf(" %p", pc[i]);
8010520b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010520e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105212:	89 44 24 04          	mov    %eax,0x4(%esp)
80105216:	c7 04 24 d8 9f 10 80 	movl   $0x80109fd8,(%esp)
8010521d:	e8 9f b1 ff ff       	call   801003c1 <cprintf>
    else{
      cprintf("%d %s %s %s TICKS: %d", p->pid, p->cont->name, state, p->name, p->ticks);
    }
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80105222:	ff 45 f4             	incl   -0xc(%ebp)
80105225:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105229:	7f 0b                	jg     80105236 <procdump+0x132>
8010522b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010522e:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105232:	85 c0                	test   %eax,%eax
80105234:	75 d5                	jne    8010520b <procdump+0x107>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105236:	c7 04 24 dc 9f 10 80 	movl   $0x80109fdc,(%esp)
8010523d:	e8 7f b1 ff ff       	call   801003c1 <cprintf>
  struct proc *p;
  char *state;
  uint pc[10];


  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105242:	81 45 f0 88 00 00 00 	addl   $0x88,-0x10(%ebp)
80105249:	81 7d f0 b4 84 11 80 	cmpl   $0x801184b4,-0x10(%ebp)
80105250:	0f 82 c1 fe ff ff    	jb     80105117 <procdump+0x13>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80105256:	83 c4 64             	add    $0x64,%esp
80105259:	5b                   	pop    %ebx
8010525a:	5d                   	pop    %ebp
8010525b:	c3                   	ret    

8010525c <cstop_container_helper>:


void cstop_container_helper(struct container* cont){
8010525c:	55                   	push   %ebp
8010525d:	89 e5                	mov    %esp,%ebp
8010525f:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105262:	c7 45 f4 b4 62 11 80 	movl   $0x801162b4,-0xc(%ebp)
80105269:	eb 37                	jmp    801052a2 <cstop_container_helper+0x46>

    if(strcmp1(p->cont->name, cont->name) == 0){
8010526b:	8b 45 08             	mov    0x8(%ebp),%eax
8010526e:	8d 50 18             	lea    0x18(%eax),%edx
80105271:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105274:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010527a:	83 c0 18             	add    $0x18,%eax
8010527d:	89 54 24 04          	mov    %edx,0x4(%esp)
80105281:	89 04 24             	mov    %eax,(%esp)
80105284:	e8 df f8 ff ff       	call   80104b68 <strcmp1>
80105289:	85 c0                	test   %eax,%eax
8010528b:	75 0e                	jne    8010529b <cstop_container_helper+0x3f>
      kill(p->pid);
8010528d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105290:	8b 40 10             	mov    0x10(%eax),%eax
80105293:	89 04 24             	mov    %eax,(%esp)
80105296:	e8 8a fd ff ff       	call   80105025 <kill>


void cstop_container_helper(struct container* cont){

  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010529b:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
801052a2:	81 7d f4 b4 84 11 80 	cmpl   $0x801184b4,-0xc(%ebp)
801052a9:	72 c0                	jb     8010526b <cstop_container_helper+0xf>
    if(strcmp1(p->cont->name, cont->name) == 0){
      kill(p->pid);
    }
  }

  container_reset(find(cont->name));
801052ab:	8b 45 08             	mov    0x8(%ebp),%eax
801052ae:	83 c0 18             	add    $0x18,%eax
801052b1:	89 04 24             	mov    %eax,(%esp)
801052b4:	e8 5e 41 00 00       	call   80109417 <find>
801052b9:	89 04 24             	mov    %eax,(%esp)
801052bc:	e8 48 47 00 00       	call   80109a09 <container_reset>
}
801052c1:	c9                   	leave  
801052c2:	c3                   	ret    

801052c3 <cstop_helper>:

void cstop_helper(char* name){
801052c3:	55                   	push   %ebp
801052c4:	89 e5                	mov    %esp,%ebp
801052c6:	83 ec 28             	sub    $0x28,%esp

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801052c9:	c7 45 f4 b4 62 11 80 	movl   $0x801162b4,-0xc(%ebp)
801052d0:	eb 69                	jmp    8010533b <cstop_helper+0x78>

    if(p->cont == NULL){
801052d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052d5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801052db:	85 c0                	test   %eax,%eax
801052dd:	75 02                	jne    801052e1 <cstop_helper+0x1e>
      continue;
801052df:	eb 53                	jmp    80105334 <cstop_helper+0x71>
    }

    if(strcmp1(p->cont->name, name) == 0){
801052e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052e4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801052ea:	8d 50 18             	lea    0x18(%eax),%edx
801052ed:	8b 45 08             	mov    0x8(%ebp),%eax
801052f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801052f4:	89 14 24             	mov    %edx,(%esp)
801052f7:	e8 6c f8 ff ff       	call   80104b68 <strcmp1>
801052fc:	85 c0                	test   %eax,%eax
801052fe:	75 34                	jne    80105334 <cstop_helper+0x71>
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
80105300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105303:	8b 40 10             	mov    0x10(%eax),%eax
80105306:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105309:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
8010530f:	83 c2 18             	add    $0x18,%edx
80105312:	89 44 24 08          	mov    %eax,0x8(%esp)
80105316:	89 54 24 04          	mov    %edx,0x4(%esp)
8010531a:	c7 04 24 e0 9f 10 80 	movl   $0x80109fe0,(%esp)
80105321:	e8 9b b0 ff ff       	call   801003c1 <cprintf>
      kill(p->pid);
80105326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105329:	8b 40 10             	mov    0x10(%eax),%eax
8010532c:	89 04 24             	mov    %eax,(%esp)
8010532f:	e8 f1 fc ff ff       	call   80105025 <kill>

void cstop_helper(char* name){

  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105334:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
8010533b:	81 7d f4 b4 84 11 80 	cmpl   $0x801184b4,-0xc(%ebp)
80105342:	72 8e                	jb     801052d2 <cstop_helper+0xf>
    if(strcmp1(p->cont->name, name) == 0){
      cprintf("killing process %s with pid %d\n", p->cont->name, p->pid);
      kill(p->pid);
    }
  }
  container_reset(find(name));
80105344:	8b 45 08             	mov    0x8(%ebp),%eax
80105347:	89 04 24             	mov    %eax,(%esp)
8010534a:	e8 c8 40 00 00       	call   80109417 <find>
8010534f:	89 04 24             	mov    %eax,(%esp)
80105352:	e8 b2 46 00 00       	call   80109a09 <container_reset>
}
80105357:	c9                   	leave  
80105358:	c3                   	ret    

80105359 <c_procdump>:

void
c_procdump(char* name)
{
80105359:	55                   	push   %ebp
8010535a:	89 e5                	mov    %esp,%ebp
8010535c:	53                   	push   %ebx
8010535d:	83 ec 34             	sub    $0x34,%esp
  //int i;
  struct proc *p;
  char *state;
  //uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105360:	c7 45 f4 b4 62 11 80 	movl   $0x801162b4,-0xc(%ebp)
80105367:	e9 c5 00 00 00       	jmp    80105431 <c_procdump+0xd8>
    if(p->state == UNUSED || p->cont == NULL)
8010536c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010536f:	8b 40 0c             	mov    0xc(%eax),%eax
80105372:	85 c0                	test   %eax,%eax
80105374:	74 0d                	je     80105383 <c_procdump+0x2a>
80105376:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105379:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010537f:	85 c0                	test   %eax,%eax
80105381:	75 05                	jne    80105388 <c_procdump+0x2f>
      continue;
80105383:	e9 a2 00 00 00       	jmp    8010542a <c_procdump+0xd1>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010538b:	8b 40 0c             	mov    0xc(%eax),%eax
8010538e:	83 f8 05             	cmp    $0x5,%eax
80105391:	77 23                	ja     801053b6 <c_procdump+0x5d>
80105393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105396:	8b 40 0c             	mov    0xc(%eax),%eax
80105399:	8b 04 85 24 d0 10 80 	mov    -0x7fef2fdc(,%eax,4),%eax
801053a0:	85 c0                	test   %eax,%eax
801053a2:	74 12                	je     801053b6 <c_procdump+0x5d>
      state = states[p->state];
801053a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053a7:	8b 40 0c             	mov    0xc(%eax),%eax
801053aa:	8b 04 85 24 d0 10 80 	mov    -0x7fef2fdc(,%eax,4),%eax
801053b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801053b4:	eb 07                	jmp    801053bd <c_procdump+0x64>
    else
      state = "???";
801053b6:	c7 45 f0 a6 9f 10 80 	movl   $0x80109fa6,-0x10(%ebp)

    if(strcmp1(p->cont->name, name) == 0){
801053bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801053c6:	8d 50 18             	lea    0x18(%eax),%edx
801053c9:	8b 45 08             	mov    0x8(%ebp),%eax
801053cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801053d0:	89 14 24             	mov    %edx,(%esp)
801053d3:	e8 90 f7 ff ff       	call   80104b68 <strcmp1>
801053d8:	85 c0                	test   %eax,%eax
801053da:	75 4e                	jne    8010542a <c_procdump+0xd1>
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d Usage: %d", 
801053dc:	8b 0d 00 8d 11 80    	mov    0x80118d00,%ecx
801053e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e5:	8b 50 7c             	mov    0x7c(%eax),%edx
801053e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053eb:	8b 40 10             	mov    0x10(%eax),%eax
        name, p->name, p->pid, state, p->ticks, ticks);
801053ee:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801053f1:	83 c3 6c             	add    $0x6c,%ebx
      state = states[p->state];
    else
      state = "???";

    if(strcmp1(p->cont->name, name) == 0){
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d Usage: %d", 
801053f4:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801053f8:	89 54 24 14          	mov    %edx,0x14(%esp)
801053fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053ff:	89 54 24 10          	mov    %edx,0x10(%esp)
80105403:	89 44 24 0c          	mov    %eax,0xc(%esp)
80105407:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010540b:	8b 45 08             	mov    0x8(%ebp),%eax
8010540e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105412:	c7 04 24 00 a0 10 80 	movl   $0x8010a000,(%esp)
80105419:	e8 a3 af ff ff       	call   801003c1 <cprintf>
        name, p->name, p->pid, state, p->ticks, ticks);
      cprintf("\n");
8010541e:	c7 04 24 dc 9f 10 80 	movl   $0x80109fdc,(%esp)
80105425:	e8 97 af ff ff       	call   801003c1 <cprintf>
  //int i;
  struct proc *p;
  char *state;
  //uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010542a:	81 45 f4 88 00 00 00 	addl   $0x88,-0xc(%ebp)
80105431:	81 7d f4 b4 84 11 80 	cmpl   $0x801184b4,-0xc(%ebp)
80105438:	0f 82 2e ff ff ff    	jb     8010536c <c_procdump+0x13>
      cprintf("     Container: %s Process: %s PID: %d State: %s Ticks: %d Usage: %d", 
        name, p->name, p->pid, state, p->ticks, ticks);
      cprintf("\n");
    }  
  }
}
8010543e:	83 c4 34             	add    $0x34,%esp
80105441:	5b                   	pop    %ebx
80105442:	5d                   	pop    %ebp
80105443:	c3                   	ret    

80105444 <pause>:

void
pause(char* name)
{
80105444:	55                   	push   %ebp
80105445:	89 e5                	mov    %esp,%ebp
80105447:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010544a:	c7 45 fc b4 62 11 80 	movl   $0x801162b4,-0x4(%ebp)
80105451:	eb 49                	jmp    8010549c <pause+0x58>
    if(p->state == UNUSED || p->cont == NULL)
80105453:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105456:	8b 40 0c             	mov    0xc(%eax),%eax
80105459:	85 c0                	test   %eax,%eax
8010545b:	74 0d                	je     8010546a <pause+0x26>
8010545d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105460:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105466:	85 c0                	test   %eax,%eax
80105468:	75 02                	jne    8010546c <pause+0x28>
      continue;
8010546a:	eb 29                	jmp    80105495 <pause+0x51>
    if(strcmp1(p->cont->name, name) == 0){
8010546c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010546f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105475:	8d 50 18             	lea    0x18(%eax),%edx
80105478:	8b 45 08             	mov    0x8(%ebp),%eax
8010547b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010547f:	89 14 24             	mov    %edx,(%esp)
80105482:	e8 e1 f6 ff ff       	call   80104b68 <strcmp1>
80105487:	85 c0                	test   %eax,%eax
80105489:	75 0a                	jne    80105495 <pause+0x51>
      p->state = ZOMBIE;
8010548b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010548e:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
void
pause(char* name)
{
  struct proc *p;
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105495:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
8010549c:	81 7d fc b4 84 11 80 	cmpl   $0x801184b4,-0x4(%ebp)
801054a3:	72 ae                	jb     80105453 <pause+0xf>
      continue;
    if(strcmp1(p->cont->name, name) == 0){
      p->state = ZOMBIE;
    }
  }
}
801054a5:	c9                   	leave  
801054a6:	c3                   	ret    

801054a7 <resume>:

void
resume(char* name)
{
801054a7:	55                   	push   %ebp
801054a8:	89 e5                	mov    %esp,%ebp
801054aa:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054ad:	c7 45 fc b4 62 11 80 	movl   $0x801162b4,-0x4(%ebp)
801054b4:	eb 3b                	jmp    801054f1 <resume+0x4a>
    if(p->state == ZOMBIE){
801054b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054b9:	8b 40 0c             	mov    0xc(%eax),%eax
801054bc:	83 f8 05             	cmp    $0x5,%eax
801054bf:	75 29                	jne    801054ea <resume+0x43>
      if(strcmp1(p->cont->name, name) == 0){
801054c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054c4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801054ca:	8d 50 18             	lea    0x18(%eax),%edx
801054cd:	8b 45 08             	mov    0x8(%ebp),%eax
801054d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801054d4:	89 14 24             	mov    %edx,(%esp)
801054d7:	e8 8c f6 ff ff       	call   80104b68 <strcmp1>
801054dc:	85 c0                	test   %eax,%eax
801054de:	75 0a                	jne    801054ea <resume+0x43>
        p->state = RUNNABLE;
801054e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054e3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
void
resume(char* name)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801054ea:	81 45 fc 88 00 00 00 	addl   $0x88,-0x4(%ebp)
801054f1:	81 7d fc b4 84 11 80 	cmpl   $0x801184b4,-0x4(%ebp)
801054f8:	72 bc                	jb     801054b6 <resume+0xf>
      if(strcmp1(p->cont->name, name) == 0){
        p->state = RUNNABLE;
      }
    }
  }
}
801054fa:	c9                   	leave  
801054fb:	c3                   	ret    

801054fc <initp>:


struct proc* initp(void){
801054fc:	55                   	push   %ebp
801054fd:	89 e5                	mov    %esp,%ebp
  return initproc;
801054ff:	a1 20 d9 10 80       	mov    0x8010d920,%eax
}
80105504:	5d                   	pop    %ebp
80105505:	c3                   	ret    

80105506 <c_proc>:

struct proc* c_proc(void){
80105506:	55                   	push   %ebp
80105507:	89 e5                	mov    %esp,%ebp
80105509:	83 ec 08             	sub    $0x8,%esp
  return myproc();
8010550c:	e8 ba f0 ff ff       	call   801045cb <myproc>
}
80105511:	c9                   	leave  
80105512:	c3                   	ret    
	...

80105514 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105514:	55                   	push   %ebp
80105515:	89 e5                	mov    %esp,%ebp
80105517:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
8010551a:	8b 45 08             	mov    0x8(%ebp),%eax
8010551d:	83 c0 04             	add    $0x4,%eax
80105520:	c7 44 24 04 6f a0 10 	movl   $0x8010a06f,0x4(%esp)
80105527:	80 
80105528:	89 04 24             	mov    %eax,(%esp)
8010552b:	e8 22 01 00 00       	call   80105652 <initlock>
  lk->name = name;
80105530:	8b 45 08             	mov    0x8(%ebp),%eax
80105533:	8b 55 0c             	mov    0xc(%ebp),%edx
80105536:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105539:	8b 45 08             	mov    0x8(%ebp),%eax
8010553c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105542:	8b 45 08             	mov    0x8(%ebp),%eax
80105545:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010554c:	c9                   	leave  
8010554d:	c3                   	ret    

8010554e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010554e:	55                   	push   %ebp
8010554f:	89 e5                	mov    %esp,%ebp
80105551:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105554:	8b 45 08             	mov    0x8(%ebp),%eax
80105557:	83 c0 04             	add    $0x4,%eax
8010555a:	89 04 24             	mov    %eax,(%esp)
8010555d:	e8 11 01 00 00       	call   80105673 <acquire>
  while (lk->locked) {
80105562:	eb 15                	jmp    80105579 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105564:	8b 45 08             	mov    0x8(%ebp),%eax
80105567:	83 c0 04             	add    $0x4,%eax
8010556a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010556e:	8b 45 08             	mov    0x8(%ebp),%eax
80105571:	89 04 24             	mov    %eax,(%esp)
80105574:	e8 aa f9 ff ff       	call   80104f23 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105579:	8b 45 08             	mov    0x8(%ebp),%eax
8010557c:	8b 00                	mov    (%eax),%eax
8010557e:	85 c0                	test   %eax,%eax
80105580:	75 e2                	jne    80105564 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80105582:	8b 45 08             	mov    0x8(%ebp),%eax
80105585:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010558b:	e8 3b f0 ff ff       	call   801045cb <myproc>
80105590:	8b 50 10             	mov    0x10(%eax),%edx
80105593:	8b 45 08             	mov    0x8(%ebp),%eax
80105596:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105599:	8b 45 08             	mov    0x8(%ebp),%eax
8010559c:	83 c0 04             	add    $0x4,%eax
8010559f:	89 04 24             	mov    %eax,(%esp)
801055a2:	e8 36 01 00 00       	call   801056dd <release>
}
801055a7:	c9                   	leave  
801055a8:	c3                   	ret    

801055a9 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801055a9:	55                   	push   %ebp
801055aa:	89 e5                	mov    %esp,%ebp
801055ac:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801055af:	8b 45 08             	mov    0x8(%ebp),%eax
801055b2:	83 c0 04             	add    $0x4,%eax
801055b5:	89 04 24             	mov    %eax,(%esp)
801055b8:	e8 b6 00 00 00       	call   80105673 <acquire>
  lk->locked = 0;
801055bd:	8b 45 08             	mov    0x8(%ebp),%eax
801055c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801055c6:	8b 45 08             	mov    0x8(%ebp),%eax
801055c9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801055d0:	8b 45 08             	mov    0x8(%ebp),%eax
801055d3:	89 04 24             	mov    %eax,(%esp)
801055d6:	e8 1f fa ff ff       	call   80104ffa <wakeup>
  release(&lk->lk);
801055db:	8b 45 08             	mov    0x8(%ebp),%eax
801055de:	83 c0 04             	add    $0x4,%eax
801055e1:	89 04 24             	mov    %eax,(%esp)
801055e4:	e8 f4 00 00 00       	call   801056dd <release>
}
801055e9:	c9                   	leave  
801055ea:	c3                   	ret    

801055eb <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801055eb:	55                   	push   %ebp
801055ec:	89 e5                	mov    %esp,%ebp
801055ee:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
801055f1:	8b 45 08             	mov    0x8(%ebp),%eax
801055f4:	83 c0 04             	add    $0x4,%eax
801055f7:	89 04 24             	mov    %eax,(%esp)
801055fa:	e8 74 00 00 00       	call   80105673 <acquire>
  r = lk->locked;
801055ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105602:	8b 00                	mov    (%eax),%eax
80105604:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105607:	8b 45 08             	mov    0x8(%ebp),%eax
8010560a:	83 c0 04             	add    $0x4,%eax
8010560d:	89 04 24             	mov    %eax,(%esp)
80105610:	e8 c8 00 00 00       	call   801056dd <release>
  return r;
80105615:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105618:	c9                   	leave  
80105619:	c3                   	ret    
	...

8010561c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010561c:	55                   	push   %ebp
8010561d:	89 e5                	mov    %esp,%ebp
8010561f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105622:	9c                   	pushf  
80105623:	58                   	pop    %eax
80105624:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105627:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010562a:	c9                   	leave  
8010562b:	c3                   	ret    

8010562c <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010562c:	55                   	push   %ebp
8010562d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010562f:	fa                   	cli    
}
80105630:	5d                   	pop    %ebp
80105631:	c3                   	ret    

80105632 <sti>:

static inline void
sti(void)
{
80105632:	55                   	push   %ebp
80105633:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105635:	fb                   	sti    
}
80105636:	5d                   	pop    %ebp
80105637:	c3                   	ret    

80105638 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105638:	55                   	push   %ebp
80105639:	89 e5                	mov    %esp,%ebp
8010563b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010563e:	8b 55 08             	mov    0x8(%ebp),%edx
80105641:	8b 45 0c             	mov    0xc(%ebp),%eax
80105644:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105647:	f0 87 02             	lock xchg %eax,(%edx)
8010564a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010564d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105650:	c9                   	leave  
80105651:	c3                   	ret    

80105652 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105652:	55                   	push   %ebp
80105653:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105655:	8b 45 08             	mov    0x8(%ebp),%eax
80105658:	8b 55 0c             	mov    0xc(%ebp),%edx
8010565b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010565e:	8b 45 08             	mov    0x8(%ebp),%eax
80105661:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105667:	8b 45 08             	mov    0x8(%ebp),%eax
8010566a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105671:	5d                   	pop    %ebp
80105672:	c3                   	ret    

80105673 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105673:	55                   	push   %ebp
80105674:	89 e5                	mov    %esp,%ebp
80105676:	53                   	push   %ebx
80105677:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010567a:	e8 53 01 00 00       	call   801057d2 <pushcli>
  if(holding(lk))
8010567f:	8b 45 08             	mov    0x8(%ebp),%eax
80105682:	89 04 24             	mov    %eax,(%esp)
80105685:	e8 17 01 00 00       	call   801057a1 <holding>
8010568a:	85 c0                	test   %eax,%eax
8010568c:	74 0c                	je     8010569a <acquire+0x27>
    panic("acquire");
8010568e:	c7 04 24 7a a0 10 80 	movl   $0x8010a07a,(%esp)
80105695:	e8 ba ae ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010569a:	90                   	nop
8010569b:	8b 45 08             	mov    0x8(%ebp),%eax
8010569e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801056a5:	00 
801056a6:	89 04 24             	mov    %eax,(%esp)
801056a9:	e8 8a ff ff ff       	call   80105638 <xchg>
801056ae:	85 c0                	test   %eax,%eax
801056b0:	75 e9                	jne    8010569b <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801056b2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801056b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
801056ba:	e8 88 ee ff ff       	call   80104547 <mycpu>
801056bf:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801056c2:	8b 45 08             	mov    0x8(%ebp),%eax
801056c5:	83 c0 0c             	add    $0xc,%eax
801056c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801056cc:	8d 45 08             	lea    0x8(%ebp),%eax
801056cf:	89 04 24             	mov    %eax,(%esp)
801056d2:	e8 53 00 00 00       	call   8010572a <getcallerpcs>
}
801056d7:	83 c4 14             	add    $0x14,%esp
801056da:	5b                   	pop    %ebx
801056db:	5d                   	pop    %ebp
801056dc:	c3                   	ret    

801056dd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801056dd:	55                   	push   %ebp
801056de:	89 e5                	mov    %esp,%ebp
801056e0:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801056e3:	8b 45 08             	mov    0x8(%ebp),%eax
801056e6:	89 04 24             	mov    %eax,(%esp)
801056e9:	e8 b3 00 00 00       	call   801057a1 <holding>
801056ee:	85 c0                	test   %eax,%eax
801056f0:	75 0c                	jne    801056fe <release+0x21>
    panic("release");
801056f2:	c7 04 24 82 a0 10 80 	movl   $0x8010a082,(%esp)
801056f9:	e8 56 ae ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
801056fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105701:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105708:	8b 45 08             	mov    0x8(%ebp),%eax
8010570b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105712:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105717:	8b 45 08             	mov    0x8(%ebp),%eax
8010571a:	8b 55 08             	mov    0x8(%ebp),%edx
8010571d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105723:	e8 f4 00 00 00       	call   8010581c <popcli>
}
80105728:	c9                   	leave  
80105729:	c3                   	ret    

8010572a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010572a:	55                   	push   %ebp
8010572b:	89 e5                	mov    %esp,%ebp
8010572d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105730:	8b 45 08             	mov    0x8(%ebp),%eax
80105733:	83 e8 08             	sub    $0x8,%eax
80105736:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105739:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105740:	eb 37                	jmp    80105779 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105742:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105746:	74 37                	je     8010577f <getcallerpcs+0x55>
80105748:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010574f:	76 2e                	jbe    8010577f <getcallerpcs+0x55>
80105751:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105755:	74 28                	je     8010577f <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105757:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010575a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105761:	8b 45 0c             	mov    0xc(%ebp),%eax
80105764:	01 c2                	add    %eax,%edx
80105766:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105769:	8b 40 04             	mov    0x4(%eax),%eax
8010576c:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010576e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105771:	8b 00                	mov    (%eax),%eax
80105773:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105776:	ff 45 f8             	incl   -0x8(%ebp)
80105779:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010577d:	7e c3                	jle    80105742 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010577f:	eb 18                	jmp    80105799 <getcallerpcs+0x6f>
    pcs[i] = 0;
80105781:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105784:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010578b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010578e:	01 d0                	add    %edx,%eax
80105790:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105796:	ff 45 f8             	incl   -0x8(%ebp)
80105799:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010579d:	7e e2                	jle    80105781 <getcallerpcs+0x57>
    pcs[i] = 0;
}
8010579f:	c9                   	leave  
801057a0:	c3                   	ret    

801057a1 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801057a1:	55                   	push   %ebp
801057a2:	89 e5                	mov    %esp,%ebp
801057a4:	53                   	push   %ebx
801057a5:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801057a8:	8b 45 08             	mov    0x8(%ebp),%eax
801057ab:	8b 00                	mov    (%eax),%eax
801057ad:	85 c0                	test   %eax,%eax
801057af:	74 16                	je     801057c7 <holding+0x26>
801057b1:	8b 45 08             	mov    0x8(%ebp),%eax
801057b4:	8b 58 08             	mov    0x8(%eax),%ebx
801057b7:	e8 8b ed ff ff       	call   80104547 <mycpu>
801057bc:	39 c3                	cmp    %eax,%ebx
801057be:	75 07                	jne    801057c7 <holding+0x26>
801057c0:	b8 01 00 00 00       	mov    $0x1,%eax
801057c5:	eb 05                	jmp    801057cc <holding+0x2b>
801057c7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057cc:	83 c4 04             	add    $0x4,%esp
801057cf:	5b                   	pop    %ebx
801057d0:	5d                   	pop    %ebp
801057d1:	c3                   	ret    

801057d2 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801057d2:	55                   	push   %ebp
801057d3:	89 e5                	mov    %esp,%ebp
801057d5:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801057d8:	e8 3f fe ff ff       	call   8010561c <readeflags>
801057dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801057e0:	e8 47 fe ff ff       	call   8010562c <cli>
  if(mycpu()->ncli == 0)
801057e5:	e8 5d ed ff ff       	call   80104547 <mycpu>
801057ea:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801057f0:	85 c0                	test   %eax,%eax
801057f2:	75 14                	jne    80105808 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801057f4:	e8 4e ed ff ff       	call   80104547 <mycpu>
801057f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057fc:	81 e2 00 02 00 00    	and    $0x200,%edx
80105802:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105808:	e8 3a ed ff ff       	call   80104547 <mycpu>
8010580d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105813:	42                   	inc    %edx
80105814:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010581a:	c9                   	leave  
8010581b:	c3                   	ret    

8010581c <popcli>:

void
popcli(void)
{
8010581c:	55                   	push   %ebp
8010581d:	89 e5                	mov    %esp,%ebp
8010581f:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105822:	e8 f5 fd ff ff       	call   8010561c <readeflags>
80105827:	25 00 02 00 00       	and    $0x200,%eax
8010582c:	85 c0                	test   %eax,%eax
8010582e:	74 0c                	je     8010583c <popcli+0x20>
    panic("popcli - interruptible");
80105830:	c7 04 24 8a a0 10 80 	movl   $0x8010a08a,(%esp)
80105837:	e8 18 ad ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
8010583c:	e8 06 ed ff ff       	call   80104547 <mycpu>
80105841:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105847:	4a                   	dec    %edx
80105848:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010584e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105854:	85 c0                	test   %eax,%eax
80105856:	79 0c                	jns    80105864 <popcli+0x48>
    panic("popcli");
80105858:	c7 04 24 a1 a0 10 80 	movl   $0x8010a0a1,(%esp)
8010585f:	e8 f0 ac ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105864:	e8 de ec ff ff       	call   80104547 <mycpu>
80105869:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010586f:	85 c0                	test   %eax,%eax
80105871:	75 14                	jne    80105887 <popcli+0x6b>
80105873:	e8 cf ec ff ff       	call   80104547 <mycpu>
80105878:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010587e:	85 c0                	test   %eax,%eax
80105880:	74 05                	je     80105887 <popcli+0x6b>
    sti();
80105882:	e8 ab fd ff ff       	call   80105632 <sti>
}
80105887:	c9                   	leave  
80105888:	c3                   	ret    
80105889:	00 00                	add    %al,(%eax)
	...

8010588c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
8010588c:	55                   	push   %ebp
8010588d:	89 e5                	mov    %esp,%ebp
8010588f:	57                   	push   %edi
80105890:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105891:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105894:	8b 55 10             	mov    0x10(%ebp),%edx
80105897:	8b 45 0c             	mov    0xc(%ebp),%eax
8010589a:	89 cb                	mov    %ecx,%ebx
8010589c:	89 df                	mov    %ebx,%edi
8010589e:	89 d1                	mov    %edx,%ecx
801058a0:	fc                   	cld    
801058a1:	f3 aa                	rep stos %al,%es:(%edi)
801058a3:	89 ca                	mov    %ecx,%edx
801058a5:	89 fb                	mov    %edi,%ebx
801058a7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801058aa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801058ad:	5b                   	pop    %ebx
801058ae:	5f                   	pop    %edi
801058af:	5d                   	pop    %ebp
801058b0:	c3                   	ret    

801058b1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801058b1:	55                   	push   %ebp
801058b2:	89 e5                	mov    %esp,%ebp
801058b4:	57                   	push   %edi
801058b5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801058b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801058b9:	8b 55 10             	mov    0x10(%ebp),%edx
801058bc:	8b 45 0c             	mov    0xc(%ebp),%eax
801058bf:	89 cb                	mov    %ecx,%ebx
801058c1:	89 df                	mov    %ebx,%edi
801058c3:	89 d1                	mov    %edx,%ecx
801058c5:	fc                   	cld    
801058c6:	f3 ab                	rep stos %eax,%es:(%edi)
801058c8:	89 ca                	mov    %ecx,%edx
801058ca:	89 fb                	mov    %edi,%ebx
801058cc:	89 5d 08             	mov    %ebx,0x8(%ebp)
801058cf:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801058d2:	5b                   	pop    %ebx
801058d3:	5f                   	pop    %edi
801058d4:	5d                   	pop    %ebp
801058d5:	c3                   	ret    

801058d6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801058d6:	55                   	push   %ebp
801058d7:	89 e5                	mov    %esp,%ebp
801058d9:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801058dc:	8b 45 08             	mov    0x8(%ebp),%eax
801058df:	83 e0 03             	and    $0x3,%eax
801058e2:	85 c0                	test   %eax,%eax
801058e4:	75 49                	jne    8010592f <memset+0x59>
801058e6:	8b 45 10             	mov    0x10(%ebp),%eax
801058e9:	83 e0 03             	and    $0x3,%eax
801058ec:	85 c0                	test   %eax,%eax
801058ee:	75 3f                	jne    8010592f <memset+0x59>
    c &= 0xFF;
801058f0:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801058f7:	8b 45 10             	mov    0x10(%ebp),%eax
801058fa:	c1 e8 02             	shr    $0x2,%eax
801058fd:	89 c2                	mov    %eax,%edx
801058ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105902:	c1 e0 18             	shl    $0x18,%eax
80105905:	89 c1                	mov    %eax,%ecx
80105907:	8b 45 0c             	mov    0xc(%ebp),%eax
8010590a:	c1 e0 10             	shl    $0x10,%eax
8010590d:	09 c1                	or     %eax,%ecx
8010590f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105912:	c1 e0 08             	shl    $0x8,%eax
80105915:	09 c8                	or     %ecx,%eax
80105917:	0b 45 0c             	or     0xc(%ebp),%eax
8010591a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010591e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105922:	8b 45 08             	mov    0x8(%ebp),%eax
80105925:	89 04 24             	mov    %eax,(%esp)
80105928:	e8 84 ff ff ff       	call   801058b1 <stosl>
8010592d:	eb 19                	jmp    80105948 <memset+0x72>
  } else
    stosb(dst, c, n);
8010592f:	8b 45 10             	mov    0x10(%ebp),%eax
80105932:	89 44 24 08          	mov    %eax,0x8(%esp)
80105936:	8b 45 0c             	mov    0xc(%ebp),%eax
80105939:	89 44 24 04          	mov    %eax,0x4(%esp)
8010593d:	8b 45 08             	mov    0x8(%ebp),%eax
80105940:	89 04 24             	mov    %eax,(%esp)
80105943:	e8 44 ff ff ff       	call   8010588c <stosb>
  return dst;
80105948:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010594b:	c9                   	leave  
8010594c:	c3                   	ret    

8010594d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010594d:	55                   	push   %ebp
8010594e:	89 e5                	mov    %esp,%ebp
80105950:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105953:	8b 45 08             	mov    0x8(%ebp),%eax
80105956:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105959:	8b 45 0c             	mov    0xc(%ebp),%eax
8010595c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010595f:	eb 2a                	jmp    8010598b <memcmp+0x3e>
    if(*s1 != *s2)
80105961:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105964:	8a 10                	mov    (%eax),%dl
80105966:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105969:	8a 00                	mov    (%eax),%al
8010596b:	38 c2                	cmp    %al,%dl
8010596d:	74 16                	je     80105985 <memcmp+0x38>
      return *s1 - *s2;
8010596f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105972:	8a 00                	mov    (%eax),%al
80105974:	0f b6 d0             	movzbl %al,%edx
80105977:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010597a:	8a 00                	mov    (%eax),%al
8010597c:	0f b6 c0             	movzbl %al,%eax
8010597f:	29 c2                	sub    %eax,%edx
80105981:	89 d0                	mov    %edx,%eax
80105983:	eb 18                	jmp    8010599d <memcmp+0x50>
    s1++, s2++;
80105985:	ff 45 fc             	incl   -0x4(%ebp)
80105988:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
8010598b:	8b 45 10             	mov    0x10(%ebp),%eax
8010598e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105991:	89 55 10             	mov    %edx,0x10(%ebp)
80105994:	85 c0                	test   %eax,%eax
80105996:	75 c9                	jne    80105961 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105998:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010599d:	c9                   	leave  
8010599e:	c3                   	ret    

8010599f <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010599f:	55                   	push   %ebp
801059a0:	89 e5                	mov    %esp,%ebp
801059a2:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801059a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801059a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801059ab:	8b 45 08             	mov    0x8(%ebp),%eax
801059ae:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801059b1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059b4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801059b7:	73 3a                	jae    801059f3 <memmove+0x54>
801059b9:	8b 45 10             	mov    0x10(%ebp),%eax
801059bc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801059bf:	01 d0                	add    %edx,%eax
801059c1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801059c4:	76 2d                	jbe    801059f3 <memmove+0x54>
    s += n;
801059c6:	8b 45 10             	mov    0x10(%ebp),%eax
801059c9:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801059cc:	8b 45 10             	mov    0x10(%ebp),%eax
801059cf:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801059d2:	eb 10                	jmp    801059e4 <memmove+0x45>
      *--d = *--s;
801059d4:	ff 4d f8             	decl   -0x8(%ebp)
801059d7:	ff 4d fc             	decl   -0x4(%ebp)
801059da:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059dd:	8a 10                	mov    (%eax),%dl
801059df:	8b 45 f8             	mov    -0x8(%ebp),%eax
801059e2:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801059e4:	8b 45 10             	mov    0x10(%ebp),%eax
801059e7:	8d 50 ff             	lea    -0x1(%eax),%edx
801059ea:	89 55 10             	mov    %edx,0x10(%ebp)
801059ed:	85 c0                	test   %eax,%eax
801059ef:	75 e3                	jne    801059d4 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801059f1:	eb 25                	jmp    80105a18 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801059f3:	eb 16                	jmp    80105a0b <memmove+0x6c>
      *d++ = *s++;
801059f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
801059f8:	8d 50 01             	lea    0x1(%eax),%edx
801059fb:	89 55 f8             	mov    %edx,-0x8(%ebp)
801059fe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a01:	8d 4a 01             	lea    0x1(%edx),%ecx
80105a04:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105a07:	8a 12                	mov    (%edx),%dl
80105a09:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80105a0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a11:	89 55 10             	mov    %edx,0x10(%ebp)
80105a14:	85 c0                	test   %eax,%eax
80105a16:	75 dd                	jne    801059f5 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105a18:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105a1b:	c9                   	leave  
80105a1c:	c3                   	ret    

80105a1d <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105a1d:	55                   	push   %ebp
80105a1e:	89 e5                	mov    %esp,%ebp
80105a20:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105a23:	8b 45 10             	mov    0x10(%ebp),%eax
80105a26:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a31:	8b 45 08             	mov    0x8(%ebp),%eax
80105a34:	89 04 24             	mov    %eax,(%esp)
80105a37:	e8 63 ff ff ff       	call   8010599f <memmove>
}
80105a3c:	c9                   	leave  
80105a3d:	c3                   	ret    

80105a3e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105a3e:	55                   	push   %ebp
80105a3f:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105a41:	eb 09                	jmp    80105a4c <strncmp+0xe>
    n--, p++, q++;
80105a43:	ff 4d 10             	decl   0x10(%ebp)
80105a46:	ff 45 08             	incl   0x8(%ebp)
80105a49:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105a4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a50:	74 17                	je     80105a69 <strncmp+0x2b>
80105a52:	8b 45 08             	mov    0x8(%ebp),%eax
80105a55:	8a 00                	mov    (%eax),%al
80105a57:	84 c0                	test   %al,%al
80105a59:	74 0e                	je     80105a69 <strncmp+0x2b>
80105a5b:	8b 45 08             	mov    0x8(%ebp),%eax
80105a5e:	8a 10                	mov    (%eax),%dl
80105a60:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a63:	8a 00                	mov    (%eax),%al
80105a65:	38 c2                	cmp    %al,%dl
80105a67:	74 da                	je     80105a43 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105a69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a6d:	75 07                	jne    80105a76 <strncmp+0x38>
    return 0;
80105a6f:	b8 00 00 00 00       	mov    $0x0,%eax
80105a74:	eb 14                	jmp    80105a8a <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
80105a76:	8b 45 08             	mov    0x8(%ebp),%eax
80105a79:	8a 00                	mov    (%eax),%al
80105a7b:	0f b6 d0             	movzbl %al,%edx
80105a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a81:	8a 00                	mov    (%eax),%al
80105a83:	0f b6 c0             	movzbl %al,%eax
80105a86:	29 c2                	sub    %eax,%edx
80105a88:	89 d0                	mov    %edx,%eax
}
80105a8a:	5d                   	pop    %ebp
80105a8b:	c3                   	ret    

80105a8c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105a8c:	55                   	push   %ebp
80105a8d:	89 e5                	mov    %esp,%ebp
80105a8f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105a92:	8b 45 08             	mov    0x8(%ebp),%eax
80105a95:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105a98:	90                   	nop
80105a99:	8b 45 10             	mov    0x10(%ebp),%eax
80105a9c:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a9f:	89 55 10             	mov    %edx,0x10(%ebp)
80105aa2:	85 c0                	test   %eax,%eax
80105aa4:	7e 1c                	jle    80105ac2 <strncpy+0x36>
80105aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80105aa9:	8d 50 01             	lea    0x1(%eax),%edx
80105aac:	89 55 08             	mov    %edx,0x8(%ebp)
80105aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
80105ab2:	8d 4a 01             	lea    0x1(%edx),%ecx
80105ab5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105ab8:	8a 12                	mov    (%edx),%dl
80105aba:	88 10                	mov    %dl,(%eax)
80105abc:	8a 00                	mov    (%eax),%al
80105abe:	84 c0                	test   %al,%al
80105ac0:	75 d7                	jne    80105a99 <strncpy+0xd>
    ;
  while(n-- > 0)
80105ac2:	eb 0c                	jmp    80105ad0 <strncpy+0x44>
    *s++ = 0;
80105ac4:	8b 45 08             	mov    0x8(%ebp),%eax
80105ac7:	8d 50 01             	lea    0x1(%eax),%edx
80105aca:	89 55 08             	mov    %edx,0x8(%ebp)
80105acd:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105ad0:	8b 45 10             	mov    0x10(%ebp),%eax
80105ad3:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ad6:	89 55 10             	mov    %edx,0x10(%ebp)
80105ad9:	85 c0                	test   %eax,%eax
80105adb:	7f e7                	jg     80105ac4 <strncpy+0x38>
    *s++ = 0;
  return os;
80105add:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ae0:	c9                   	leave  
80105ae1:	c3                   	ret    

80105ae2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105ae2:	55                   	push   %ebp
80105ae3:	89 e5                	mov    %esp,%ebp
80105ae5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80105aeb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105aee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105af2:	7f 05                	jg     80105af9 <safestrcpy+0x17>
    return os;
80105af4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105af7:	eb 2e                	jmp    80105b27 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105af9:	ff 4d 10             	decl   0x10(%ebp)
80105afc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b00:	7e 1c                	jle    80105b1e <safestrcpy+0x3c>
80105b02:	8b 45 08             	mov    0x8(%ebp),%eax
80105b05:	8d 50 01             	lea    0x1(%eax),%edx
80105b08:	89 55 08             	mov    %edx,0x8(%ebp)
80105b0b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b0e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105b11:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105b14:	8a 12                	mov    (%edx),%dl
80105b16:	88 10                	mov    %dl,(%eax)
80105b18:	8a 00                	mov    (%eax),%al
80105b1a:	84 c0                	test   %al,%al
80105b1c:	75 db                	jne    80105af9 <safestrcpy+0x17>
    ;
  *s = 0;
80105b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b21:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105b24:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b27:	c9                   	leave  
80105b28:	c3                   	ret    

80105b29 <strlen>:

int
strlen(const char *s)
{
80105b29:	55                   	push   %ebp
80105b2a:	89 e5                	mov    %esp,%ebp
80105b2c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105b2f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105b36:	eb 03                	jmp    80105b3b <strlen+0x12>
80105b38:	ff 45 fc             	incl   -0x4(%ebp)
80105b3b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b41:	01 d0                	add    %edx,%eax
80105b43:	8a 00                	mov    (%eax),%al
80105b45:	84 c0                	test   %al,%al
80105b47:	75 ef                	jne    80105b38 <strlen+0xf>
    ;
  return n;
80105b49:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105b4c:	c9                   	leave  
80105b4d:	c3                   	ret    
	...

80105b50 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105b50:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105b54:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105b58:	55                   	push   %ebp
  pushl %ebx
80105b59:	53                   	push   %ebx
  pushl %esi
80105b5a:	56                   	push   %esi
  pushl %edi
80105b5b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105b5c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105b5e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105b60:	5f                   	pop    %edi
  popl %esi
80105b61:	5e                   	pop    %esi
  popl %ebx
80105b62:	5b                   	pop    %ebx
  popl %ebp
80105b63:	5d                   	pop    %ebp
  ret
80105b64:	c3                   	ret    
80105b65:	00 00                	add    %al,(%eax)
	...

80105b68 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105b68:	55                   	push   %ebp
80105b69:	89 e5                	mov    %esp,%ebp
80105b6b:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105b6e:	e8 58 ea ff ff       	call   801045cb <myproc>
80105b73:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b79:	8b 00                	mov    (%eax),%eax
80105b7b:	3b 45 08             	cmp    0x8(%ebp),%eax
80105b7e:	76 0f                	jbe    80105b8f <fetchint+0x27>
80105b80:	8b 45 08             	mov    0x8(%ebp),%eax
80105b83:	8d 50 04             	lea    0x4(%eax),%edx
80105b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b89:	8b 00                	mov    (%eax),%eax
80105b8b:	39 c2                	cmp    %eax,%edx
80105b8d:	76 07                	jbe    80105b96 <fetchint+0x2e>
    return -1;
80105b8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b94:	eb 0f                	jmp    80105ba5 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105b96:	8b 45 08             	mov    0x8(%ebp),%eax
80105b99:	8b 10                	mov    (%eax),%edx
80105b9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b9e:	89 10                	mov    %edx,(%eax)
  return 0;
80105ba0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ba5:	c9                   	leave  
80105ba6:	c3                   	ret    

80105ba7 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105ba7:	55                   	push   %ebp
80105ba8:	89 e5                	mov    %esp,%ebp
80105baa:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105bad:	e8 19 ea ff ff       	call   801045cb <myproc>
80105bb2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105bb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb8:	8b 00                	mov    (%eax),%eax
80105bba:	3b 45 08             	cmp    0x8(%ebp),%eax
80105bbd:	77 07                	ja     80105bc6 <fetchstr+0x1f>
    return -1;
80105bbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc4:	eb 41                	jmp    80105c07 <fetchstr+0x60>
  *pp = (char*)addr;
80105bc6:	8b 55 08             	mov    0x8(%ebp),%edx
80105bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bcc:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105bce:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bd1:	8b 00                	mov    (%eax),%eax
80105bd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bd9:	8b 00                	mov    (%eax),%eax
80105bdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bde:	eb 1a                	jmp    80105bfa <fetchstr+0x53>
    if(*s == 0)
80105be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be3:	8a 00                	mov    (%eax),%al
80105be5:	84 c0                	test   %al,%al
80105be7:	75 0e                	jne    80105bf7 <fetchstr+0x50>
      return s - *pp;
80105be9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bec:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bef:	8b 00                	mov    (%eax),%eax
80105bf1:	29 c2                	sub    %eax,%edx
80105bf3:	89 d0                	mov    %edx,%eax
80105bf5:	eb 10                	jmp    80105c07 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105bf7:	ff 45 f4             	incl   -0xc(%ebp)
80105bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105c00:	72 de                	jb     80105be0 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105c02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c07:	c9                   	leave  
80105c08:	c3                   	ret    

80105c09 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105c09:	55                   	push   %ebp
80105c0a:	89 e5                	mov    %esp,%ebp
80105c0c:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105c0f:	e8 b7 e9 ff ff       	call   801045cb <myproc>
80105c14:	8b 40 18             	mov    0x18(%eax),%eax
80105c17:	8b 50 44             	mov    0x44(%eax),%edx
80105c1a:	8b 45 08             	mov    0x8(%ebp),%eax
80105c1d:	c1 e0 02             	shl    $0x2,%eax
80105c20:	01 d0                	add    %edx,%eax
80105c22:	8d 50 04             	lea    0x4(%eax),%edx
80105c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c28:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c2c:	89 14 24             	mov    %edx,(%esp)
80105c2f:	e8 34 ff ff ff       	call   80105b68 <fetchint>
}
80105c34:	c9                   	leave  
80105c35:	c3                   	ret    

80105c36 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105c36:	55                   	push   %ebp
80105c37:	89 e5                	mov    %esp,%ebp
80105c39:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105c3c:	e8 8a e9 ff ff       	call   801045cb <myproc>
80105c41:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105c44:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c47:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80105c4e:	89 04 24             	mov    %eax,(%esp)
80105c51:	e8 b3 ff ff ff       	call   80105c09 <argint>
80105c56:	85 c0                	test   %eax,%eax
80105c58:	79 07                	jns    80105c61 <argptr+0x2b>
    return -1;
80105c5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c5f:	eb 3d                	jmp    80105c9e <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105c61:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c65:	78 21                	js     80105c88 <argptr+0x52>
80105c67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6a:	89 c2                	mov    %eax,%edx
80105c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6f:	8b 00                	mov    (%eax),%eax
80105c71:	39 c2                	cmp    %eax,%edx
80105c73:	73 13                	jae    80105c88 <argptr+0x52>
80105c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c78:	89 c2                	mov    %eax,%edx
80105c7a:	8b 45 10             	mov    0x10(%ebp),%eax
80105c7d:	01 c2                	add    %eax,%edx
80105c7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c82:	8b 00                	mov    (%eax),%eax
80105c84:	39 c2                	cmp    %eax,%edx
80105c86:	76 07                	jbe    80105c8f <argptr+0x59>
    return -1;
80105c88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c8d:	eb 0f                	jmp    80105c9e <argptr+0x68>
  *pp = (char*)i;
80105c8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c92:	89 c2                	mov    %eax,%edx
80105c94:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c97:	89 10                	mov    %edx,(%eax)
  return 0;
80105c99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c9e:	c9                   	leave  
80105c9f:	c3                   	ret    

80105ca0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105ca0:	55                   	push   %ebp
80105ca1:	89 e5                	mov    %esp,%ebp
80105ca3:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cad:	8b 45 08             	mov    0x8(%ebp),%eax
80105cb0:	89 04 24             	mov    %eax,(%esp)
80105cb3:	e8 51 ff ff ff       	call   80105c09 <argint>
80105cb8:	85 c0                	test   %eax,%eax
80105cba:	79 07                	jns    80105cc3 <argstr+0x23>
    return -1;
80105cbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc1:	eb 12                	jmp    80105cd5 <argstr+0x35>
  return fetchstr(addr, pp);
80105cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc6:	8b 55 0c             	mov    0xc(%ebp),%edx
80105cc9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ccd:	89 04 24             	mov    %eax,(%esp)
80105cd0:	e8 d2 fe ff ff       	call   80105ba7 <fetchstr>
}
80105cd5:	c9                   	leave  
80105cd6:	c3                   	ret    

80105cd7 <syscall>:
[SYS_get_used] sys_get_used,
};

void
syscall(void)
{
80105cd7:	55                   	push   %ebp
80105cd8:	89 e5                	mov    %esp,%ebp
80105cda:	53                   	push   %ebx
80105cdb:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105cde:	e8 e8 e8 ff ff       	call   801045cb <myproc>
80105ce3:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105ce6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce9:	8b 40 18             	mov    0x18(%eax),%eax
80105cec:	8b 40 1c             	mov    0x1c(%eax),%eax
80105cef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105cf2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105cf6:	7e 2d                	jle    80105d25 <syscall+0x4e>
80105cf8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cfb:	83 f8 35             	cmp    $0x35,%eax
80105cfe:	77 25                	ja     80105d25 <syscall+0x4e>
80105d00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d03:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105d0a:	85 c0                	test   %eax,%eax
80105d0c:	74 17                	je     80105d25 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105d0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d11:	8b 58 18             	mov    0x18(%eax),%ebx
80105d14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d17:	8b 04 85 40 d0 10 80 	mov    -0x7fef2fc0(,%eax,4),%eax
80105d1e:	ff d0                	call   *%eax
80105d20:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105d23:	eb 34                	jmp    80105d59 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105d25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d28:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2e:	8b 40 10             	mov    0x10(%eax),%eax
80105d31:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d34:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105d38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105d3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d40:	c7 04 24 a8 a0 10 80 	movl   $0x8010a0a8,(%esp)
80105d47:	e8 75 a6 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4f:	8b 40 18             	mov    0x18(%eax),%eax
80105d52:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105d59:	83 c4 24             	add    $0x24,%esp
80105d5c:	5b                   	pop    %ebx
80105d5d:	5d                   	pop    %ebp
80105d5e:	c3                   	ret    
	...

80105d60 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105d60:	55                   	push   %ebp
80105d61:	89 e5                	mov    %esp,%ebp
80105d63:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105d66:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d69:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d6d:	8b 45 08             	mov    0x8(%ebp),%eax
80105d70:	89 04 24             	mov    %eax,(%esp)
80105d73:	e8 91 fe ff ff       	call   80105c09 <argint>
80105d78:	85 c0                	test   %eax,%eax
80105d7a:	79 07                	jns    80105d83 <argfd+0x23>
    return -1;
80105d7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d81:	eb 4f                	jmp    80105dd2 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d86:	85 c0                	test   %eax,%eax
80105d88:	78 20                	js     80105daa <argfd+0x4a>
80105d8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d8d:	83 f8 0f             	cmp    $0xf,%eax
80105d90:	7f 18                	jg     80105daa <argfd+0x4a>
80105d92:	e8 34 e8 ff ff       	call   801045cb <myproc>
80105d97:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105d9a:	83 c2 08             	add    $0x8,%edx
80105d9d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105da1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105da4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105da8:	75 07                	jne    80105db1 <argfd+0x51>
    return -1;
80105daa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105daf:	eb 21                	jmp    80105dd2 <argfd+0x72>
  if(pfd)
80105db1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105db5:	74 08                	je     80105dbf <argfd+0x5f>
    *pfd = fd;
80105db7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105dba:	8b 45 0c             	mov    0xc(%ebp),%eax
80105dbd:	89 10                	mov    %edx,(%eax)
  if(pf)
80105dbf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105dc3:	74 08                	je     80105dcd <argfd+0x6d>
    *pf = f;
80105dc5:	8b 45 10             	mov    0x10(%ebp),%eax
80105dc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105dcb:	89 10                	mov    %edx,(%eax)
  return 0;
80105dcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105dd2:	c9                   	leave  
80105dd3:	c3                   	ret    

80105dd4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105dd4:	55                   	push   %ebp
80105dd5:	89 e5                	mov    %esp,%ebp
80105dd7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105dda:	e8 ec e7 ff ff       	call   801045cb <myproc>
80105ddf:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105de2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105de9:	eb 29                	jmp    80105e14 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105deb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dee:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105df1:	83 c2 08             	add    $0x8,%edx
80105df4:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105df8:	85 c0                	test   %eax,%eax
80105dfa:	75 15                	jne    80105e11 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105dfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e02:	8d 4a 08             	lea    0x8(%edx),%ecx
80105e05:	8b 55 08             	mov    0x8(%ebp),%edx
80105e08:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e0f:	eb 0e                	jmp    80105e1f <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105e11:	ff 45 f4             	incl   -0xc(%ebp)
80105e14:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105e18:	7e d1                	jle    80105deb <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105e1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e1f:	c9                   	leave  
80105e20:	c3                   	ret    

80105e21 <sys_dup>:

int
sys_dup(void)
{
80105e21:	55                   	push   %ebp
80105e22:	89 e5                	mov    %esp,%ebp
80105e24:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105e27:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e2a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e2e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e35:	00 
80105e36:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e3d:	e8 1e ff ff ff       	call   80105d60 <argfd>
80105e42:	85 c0                	test   %eax,%eax
80105e44:	79 07                	jns    80105e4d <sys_dup+0x2c>
    return -1;
80105e46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e4b:	eb 29                	jmp    80105e76 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e50:	89 04 24             	mov    %eax,(%esp)
80105e53:	e8 7c ff ff ff       	call   80105dd4 <fdalloc>
80105e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e5b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e5f:	79 07                	jns    80105e68 <sys_dup+0x47>
    return -1;
80105e61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e66:	eb 0e                	jmp    80105e76 <sys_dup+0x55>
  filedup(f);
80105e68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e6b:	89 04 24             	mov    %eax,(%esp)
80105e6e:	e8 ef b2 ff ff       	call   80101162 <filedup>
  return fd;
80105e73:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105e76:	c9                   	leave  
80105e77:	c3                   	ret    

80105e78 <sys_read>:

int
sys_read(void)
{
80105e78:	55                   	push   %ebp
80105e79:	89 e5                	mov    %esp,%ebp
80105e7b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105e7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e81:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e85:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e8c:	00 
80105e8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e94:	e8 c7 fe ff ff       	call   80105d60 <argfd>
80105e99:	85 c0                	test   %eax,%eax
80105e9b:	78 35                	js     80105ed2 <sys_read+0x5a>
80105e9d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ea4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105eab:	e8 59 fd ff ff       	call   80105c09 <argint>
80105eb0:	85 c0                	test   %eax,%eax
80105eb2:	78 1e                	js     80105ed2 <sys_read+0x5a>
80105eb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eb7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ebb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105ebe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ec2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ec9:	e8 68 fd ff ff       	call   80105c36 <argptr>
80105ece:	85 c0                	test   %eax,%eax
80105ed0:	79 07                	jns    80105ed9 <sys_read+0x61>
    return -1;
80105ed2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ed7:	eb 19                	jmp    80105ef2 <sys_read+0x7a>
  return fileread(f, p, n);
80105ed9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105edc:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ee2:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105ee6:	89 54 24 04          	mov    %edx,0x4(%esp)
80105eea:	89 04 24             	mov    %eax,(%esp)
80105eed:	e8 d1 b3 ff ff       	call   801012c3 <fileread>
}
80105ef2:	c9                   	leave  
80105ef3:	c3                   	ret    

80105ef4 <sys_write>:

int
sys_write(void)
{
80105ef4:	55                   	push   %ebp
80105ef5:	89 e5                	mov    %esp,%ebp
80105ef7:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105efa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105efd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f01:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f08:	00 
80105f09:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f10:	e8 4b fe ff ff       	call   80105d60 <argfd>
80105f15:	85 c0                	test   %eax,%eax
80105f17:	78 35                	js     80105f4e <sys_write+0x5a>
80105f19:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f20:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105f27:	e8 dd fc ff ff       	call   80105c09 <argint>
80105f2c:	85 c0                	test   %eax,%eax
80105f2e:	78 1e                	js     80105f4e <sys_write+0x5a>
80105f30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f33:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f37:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f3e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f45:	e8 ec fc ff ff       	call   80105c36 <argptr>
80105f4a:	85 c0                	test   %eax,%eax
80105f4c:	79 07                	jns    80105f55 <sys_write+0x61>
    return -1;
80105f4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f53:	eb 19                	jmp    80105f6e <sys_write+0x7a>
  return filewrite(f, p, n);
80105f55:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105f58:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105f62:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f66:	89 04 24             	mov    %eax,(%esp)
80105f69:	e8 10 b4 ff ff       	call   8010137e <filewrite>
}
80105f6e:	c9                   	leave  
80105f6f:	c3                   	ret    

80105f70 <sys_close>:

int
sys_close(void)
{
80105f70:	55                   	push   %ebp
80105f71:	89 e5                	mov    %esp,%ebp
80105f73:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105f76:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f79:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f80:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f8b:	e8 d0 fd ff ff       	call   80105d60 <argfd>
80105f90:	85 c0                	test   %eax,%eax
80105f92:	79 07                	jns    80105f9b <sys_close+0x2b>
    return -1;
80105f94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f99:	eb 23                	jmp    80105fbe <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105f9b:	e8 2b e6 ff ff       	call   801045cb <myproc>
80105fa0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fa3:	83 c2 08             	add    $0x8,%edx
80105fa6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105fad:	00 
  fileclose(f);
80105fae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb1:	89 04 24             	mov    %eax,(%esp)
80105fb4:	e8 f1 b1 ff ff       	call   801011aa <fileclose>
  return 0;
80105fb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105fbe:	c9                   	leave  
80105fbf:	c3                   	ret    

80105fc0 <sys_fstat>:

int
sys_fstat(void)
{
80105fc0:	55                   	push   %ebp
80105fc1:	89 e5                	mov    %esp,%ebp
80105fc3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105fc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fc9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fcd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105fd4:	00 
80105fd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fdc:	e8 7f fd ff ff       	call   80105d60 <argfd>
80105fe1:	85 c0                	test   %eax,%eax
80105fe3:	78 1f                	js     80106004 <sys_fstat+0x44>
80105fe5:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105fec:	00 
80105fed:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ff0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ff4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105ffb:	e8 36 fc ff ff       	call   80105c36 <argptr>
80106000:	85 c0                	test   %eax,%eax
80106002:	79 07                	jns    8010600b <sys_fstat+0x4b>
    return -1;
80106004:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106009:	eb 12                	jmp    8010601d <sys_fstat+0x5d>
  return filestat(f, st);
8010600b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010600e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106011:	89 54 24 04          	mov    %edx,0x4(%esp)
80106015:	89 04 24             	mov    %eax,(%esp)
80106018:	e8 57 b2 ff ff       	call   80101274 <filestat>
}
8010601d:	c9                   	leave  
8010601e:	c3                   	ret    

8010601f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010601f:	55                   	push   %ebp
80106020:	89 e5                	mov    %esp,%ebp
80106022:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80106025:	8d 45 d8             	lea    -0x28(%ebp),%eax
80106028:	89 44 24 04          	mov    %eax,0x4(%esp)
8010602c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106033:	e8 68 fc ff ff       	call   80105ca0 <argstr>
80106038:	85 c0                	test   %eax,%eax
8010603a:	78 17                	js     80106053 <sys_link+0x34>
8010603c:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010603f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106043:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010604a:	e8 51 fc ff ff       	call   80105ca0 <argstr>
8010604f:	85 c0                	test   %eax,%eax
80106051:	79 0a                	jns    8010605d <sys_link+0x3e>
    return -1;
80106053:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106058:	e9 3d 01 00 00       	jmp    8010619a <sys_link+0x17b>

  begin_op();
8010605d:	e8 69 d8 ff ff       	call   801038cb <begin_op>
  if((ip = namei(old)) == 0){
80106062:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106065:	89 04 24             	mov    %eax,(%esp)
80106068:	e8 5b c7 ff ff       	call   801027c8 <namei>
8010606d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106070:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106074:	75 0f                	jne    80106085 <sys_link+0x66>
    end_op();
80106076:	e8 d2 d8 ff ff       	call   8010394d <end_op>
    return -1;
8010607b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106080:	e9 15 01 00 00       	jmp    8010619a <sys_link+0x17b>
  }

  ilock(ip);
80106085:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106088:	89 04 24             	mov    %eax,(%esp)
8010608b:	e8 97 ba ff ff       	call   80101b27 <ilock>
  if(ip->type == T_DIR){
80106090:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106093:	8b 40 50             	mov    0x50(%eax),%eax
80106096:	66 83 f8 01          	cmp    $0x1,%ax
8010609a:	75 1a                	jne    801060b6 <sys_link+0x97>
    iunlockput(ip);
8010609c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609f:	89 04 24             	mov    %eax,(%esp)
801060a2:	e8 7f bc ff ff       	call   80101d26 <iunlockput>
    end_op();
801060a7:	e8 a1 d8 ff ff       	call   8010394d <end_op>
    return -1;
801060ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b1:	e9 e4 00 00 00       	jmp    8010619a <sys_link+0x17b>
  }

  ip->nlink++;
801060b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060b9:	66 8b 40 56          	mov    0x56(%eax),%ax
801060bd:	40                   	inc    %eax
801060be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060c1:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801060c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060c8:	89 04 24             	mov    %eax,(%esp)
801060cb:	e8 94 b8 ff ff       	call   80101964 <iupdate>
  iunlock(ip);
801060d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060d3:	89 04 24             	mov    %eax,(%esp)
801060d6:	e8 56 bb ff ff       	call   80101c31 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801060db:	8b 45 dc             	mov    -0x24(%ebp),%eax
801060de:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801060e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801060e5:	89 04 24             	mov    %eax,(%esp)
801060e8:	e8 fd c6 ff ff       	call   801027ea <nameiparent>
801060ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060f0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060f4:	75 02                	jne    801060f8 <sys_link+0xd9>
    goto bad;
801060f6:	eb 68                	jmp    80106160 <sys_link+0x141>
  ilock(dp);
801060f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fb:	89 04 24             	mov    %eax,(%esp)
801060fe:	e8 24 ba ff ff       	call   80101b27 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106103:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106106:	8b 10                	mov    (%eax),%edx
80106108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610b:	8b 00                	mov    (%eax),%eax
8010610d:	39 c2                	cmp    %eax,%edx
8010610f:	75 20                	jne    80106131 <sys_link+0x112>
80106111:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106114:	8b 40 04             	mov    0x4(%eax),%eax
80106117:	89 44 24 08          	mov    %eax,0x8(%esp)
8010611b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010611e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106122:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106125:	89 04 24             	mov    %eax,(%esp)
80106128:	e8 e0 c2 ff ff       	call   8010240d <dirlink>
8010612d:	85 c0                	test   %eax,%eax
8010612f:	79 0d                	jns    8010613e <sys_link+0x11f>
    iunlockput(dp);
80106131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106134:	89 04 24             	mov    %eax,(%esp)
80106137:	e8 ea bb ff ff       	call   80101d26 <iunlockput>
    goto bad;
8010613c:	eb 22                	jmp    80106160 <sys_link+0x141>
  }
  iunlockput(dp);
8010613e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106141:	89 04 24             	mov    %eax,(%esp)
80106144:	e8 dd bb ff ff       	call   80101d26 <iunlockput>
  iput(ip);
80106149:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010614c:	89 04 24             	mov    %eax,(%esp)
8010614f:	e8 21 bb ff ff       	call   80101c75 <iput>

  end_op();
80106154:	e8 f4 d7 ff ff       	call   8010394d <end_op>

  return 0;
80106159:	b8 00 00 00 00       	mov    $0x0,%eax
8010615e:	eb 3a                	jmp    8010619a <sys_link+0x17b>

bad:
  ilock(ip);
80106160:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106163:	89 04 24             	mov    %eax,(%esp)
80106166:	e8 bc b9 ff ff       	call   80101b27 <ilock>
  ip->nlink--;
8010616b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010616e:	66 8b 40 56          	mov    0x56(%eax),%ax
80106172:	48                   	dec    %eax
80106173:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106176:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010617a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010617d:	89 04 24             	mov    %eax,(%esp)
80106180:	e8 df b7 ff ff       	call   80101964 <iupdate>
  iunlockput(ip);
80106185:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106188:	89 04 24             	mov    %eax,(%esp)
8010618b:	e8 96 bb ff ff       	call   80101d26 <iunlockput>
  end_op();
80106190:	e8 b8 d7 ff ff       	call   8010394d <end_op>
  return -1;
80106195:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010619a:	c9                   	leave  
8010619b:	c3                   	ret    

8010619c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010619c:	55                   	push   %ebp
8010619d:	89 e5                	mov    %esp,%ebp
8010619f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801061a2:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801061a9:	eb 4a                	jmp    801061f5 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801061ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ae:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801061b5:	00 
801061b6:	89 44 24 08          	mov    %eax,0x8(%esp)
801061ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801061c1:	8b 45 08             	mov    0x8(%ebp),%eax
801061c4:	89 04 24             	mov    %eax,(%esp)
801061c7:	e8 f2 bd ff ff       	call   80101fbe <readi>
801061cc:	83 f8 10             	cmp    $0x10,%eax
801061cf:	74 0c                	je     801061dd <isdirempty+0x41>
      panic("isdirempty: readi");
801061d1:	c7 04 24 c4 a0 10 80 	movl   $0x8010a0c4,(%esp)
801061d8:	e8 77 a3 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
801061dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e0:	66 85 c0             	test   %ax,%ax
801061e3:	74 07                	je     801061ec <isdirempty+0x50>
      return 0;
801061e5:	b8 00 00 00 00       	mov    $0x0,%eax
801061ea:	eb 1b                	jmp    80106207 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801061ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ef:	83 c0 10             	add    $0x10,%eax
801061f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061f8:	8b 45 08             	mov    0x8(%ebp),%eax
801061fb:	8b 40 58             	mov    0x58(%eax),%eax
801061fe:	39 c2                	cmp    %eax,%edx
80106200:	72 a9                	jb     801061ab <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106202:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106207:	c9                   	leave  
80106208:	c3                   	ret    

80106209 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106209:	55                   	push   %ebp
8010620a:	89 e5                	mov    %esp,%ebp
8010620c:	83 ec 58             	sub    $0x58,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010620f:	8d 45 bc             	lea    -0x44(%ebp),%eax
80106212:	89 44 24 04          	mov    %eax,0x4(%esp)
80106216:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010621d:	e8 7e fa ff ff       	call   80105ca0 <argstr>
80106222:	85 c0                	test   %eax,%eax
80106224:	79 0a                	jns    80106230 <sys_unlink+0x27>
    return -1;
80106226:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622b:	e9 f1 01 00 00       	jmp    80106421 <sys_unlink+0x218>

  begin_op();
80106230:	e8 96 d6 ff ff       	call   801038cb <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106235:	8b 45 bc             	mov    -0x44(%ebp),%eax
80106238:	8d 55 c2             	lea    -0x3e(%ebp),%edx
8010623b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010623f:	89 04 24             	mov    %eax,(%esp)
80106242:	e8 a3 c5 ff ff       	call   801027ea <nameiparent>
80106247:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010624a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010624e:	75 0f                	jne    8010625f <sys_unlink+0x56>
    end_op();
80106250:	e8 f8 d6 ff ff       	call   8010394d <end_op>
    return -1;
80106255:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010625a:	e9 c2 01 00 00       	jmp    80106421 <sys_unlink+0x218>
  }

  ilock(dp);
8010625f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106262:	89 04 24             	mov    %eax,(%esp)
80106265:	e8 bd b8 ff ff       	call   80101b27 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010626a:	c7 44 24 04 d6 a0 10 	movl   $0x8010a0d6,0x4(%esp)
80106271:	80 
80106272:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80106275:	89 04 24             	mov    %eax,(%esp)
80106278:	e8 a8 c0 ff ff       	call   80102325 <namecmp>
8010627d:	85 c0                	test   %eax,%eax
8010627f:	0f 84 87 01 00 00    	je     8010640c <sys_unlink+0x203>
80106285:	c7 44 24 04 d8 a0 10 	movl   $0x8010a0d8,0x4(%esp)
8010628c:	80 
8010628d:	8d 45 c2             	lea    -0x3e(%ebp),%eax
80106290:	89 04 24             	mov    %eax,(%esp)
80106293:	e8 8d c0 ff ff       	call   80102325 <namecmp>
80106298:	85 c0                	test   %eax,%eax
8010629a:	0f 84 6c 01 00 00    	je     8010640c <sys_unlink+0x203>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801062a0:	8d 45 b8             	lea    -0x48(%ebp),%eax
801062a3:	89 44 24 08          	mov    %eax,0x8(%esp)
801062a7:	8d 45 c2             	lea    -0x3e(%ebp),%eax
801062aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801062ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062b1:	89 04 24             	mov    %eax,(%esp)
801062b4:	e8 8e c0 ff ff       	call   80102347 <dirlookup>
801062b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801062bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801062c0:	75 05                	jne    801062c7 <sys_unlink+0xbe>
    goto bad;
801062c2:	e9 45 01 00 00       	jmp    8010640c <sys_unlink+0x203>
  ilock(ip);
801062c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ca:	89 04 24             	mov    %eax,(%esp)
801062cd:	e8 55 b8 ff ff       	call   80101b27 <ilock>

  if(ip->nlink < 1)
801062d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d5:	66 8b 40 56          	mov    0x56(%eax),%ax
801062d9:	66 85 c0             	test   %ax,%ax
801062dc:	7f 0c                	jg     801062ea <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801062de:	c7 04 24 db a0 10 80 	movl   $0x8010a0db,(%esp)
801062e5:	e8 6a a2 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801062ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062ed:	8b 40 50             	mov    0x50(%eax),%eax
801062f0:	66 83 f8 01          	cmp    $0x1,%ax
801062f4:	75 1f                	jne    80106315 <sys_unlink+0x10c>
801062f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062f9:	89 04 24             	mov    %eax,(%esp)
801062fc:	e8 9b fe ff ff       	call   8010619c <isdirempty>
80106301:	85 c0                	test   %eax,%eax
80106303:	75 10                	jne    80106315 <sys_unlink+0x10c>
    iunlockput(ip);
80106305:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106308:	89 04 24             	mov    %eax,(%esp)
8010630b:	e8 16 ba ff ff       	call   80101d26 <iunlockput>
    goto bad;
80106310:	e9 f7 00 00 00       	jmp    8010640c <sys_unlink+0x203>
  }

  memset(&de, 0, sizeof(de));
80106315:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010631c:	00 
8010631d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106324:	00 
80106325:	8d 45 d0             	lea    -0x30(%ebp),%eax
80106328:	89 04 24             	mov    %eax,(%esp)
8010632b:	e8 a6 f5 ff ff       	call   801058d6 <memset>
  int z = writei(dp, (char*)&de, off, sizeof(de));
80106330:	8b 45 b8             	mov    -0x48(%ebp),%eax
80106333:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010633a:	00 
8010633b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010633f:	8d 45 d0             	lea    -0x30(%ebp),%eax
80106342:	89 44 24 04          	mov    %eax,0x4(%esp)
80106346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106349:	89 04 24             	mov    %eax,(%esp)
8010634c:	e8 d1 bd ff ff       	call   80102122 <writei>
80106351:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(z != sizeof(de))
80106354:	83 7d ec 10          	cmpl   $0x10,-0x14(%ebp)
80106358:	74 0c                	je     80106366 <sys_unlink+0x15d>
    panic("unlink: writei");
8010635a:	c7 04 24 ed a0 10 80 	movl   $0x8010a0ed,(%esp)
80106361:	e8 ee a1 ff ff       	call   80100554 <panic>

  char *c_name = myproc()->cont->name;
80106366:	e8 60 e2 ff ff       	call   801045cb <myproc>
8010636b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106371:	83 c0 18             	add    $0x18,%eax
80106374:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int x = find(c_name);
80106377:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010637a:	89 04 24             	mov    %eax,(%esp)
8010637d:	e8 95 30 00 00       	call   80109417 <find>
80106382:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int set = z/2;
80106385:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106388:	89 c2                	mov    %eax,%edx
8010638a:	c1 ea 1f             	shr    $0x1f,%edx
8010638d:	01 d0                	add    %edx,%eax
8010638f:	d1 f8                	sar    %eax
80106391:	89 45 e0             	mov    %eax,-0x20(%ebp)
  // cprintf("DECREMENTING %d \n", set);
  set_curr_disk(-set, x);
80106394:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106397:	f7 d8                	neg    %eax
80106399:	89 c2                	mov    %eax,%edx
8010639b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010639e:	89 44 24 04          	mov    %eax,0x4(%esp)
801063a2:	89 14 24             	mov    %edx,(%esp)
801063a5:	e8 02 34 00 00       	call   801097ac <set_curr_disk>
  if(ip->type == T_DIR){
801063aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ad:	8b 40 50             	mov    0x50(%eax),%eax
801063b0:	66 83 f8 01          	cmp    $0x1,%ax
801063b4:	75 1a                	jne    801063d0 <sys_unlink+0x1c7>
    dp->nlink--;
801063b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b9:	66 8b 40 56          	mov    0x56(%eax),%ax
801063bd:	48                   	dec    %eax
801063be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063c1:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
801063c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c8:	89 04 24             	mov    %eax,(%esp)
801063cb:	e8 94 b5 ff ff       	call   80101964 <iupdate>
  }
  iunlockput(dp);
801063d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d3:	89 04 24             	mov    %eax,(%esp)
801063d6:	e8 4b b9 ff ff       	call   80101d26 <iunlockput>

  ip->nlink--;
801063db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063de:	66 8b 40 56          	mov    0x56(%eax),%ax
801063e2:	48                   	dec    %eax
801063e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063e6:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801063ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063ed:	89 04 24             	mov    %eax,(%esp)
801063f0:	e8 6f b5 ff ff       	call   80101964 <iupdate>
  iunlockput(ip);
801063f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f8:	89 04 24             	mov    %eax,(%esp)
801063fb:	e8 26 b9 ff ff       	call   80101d26 <iunlockput>

  end_op();
80106400:	e8 48 d5 ff ff       	call   8010394d <end_op>

  return 0;
80106405:	b8 00 00 00 00       	mov    $0x0,%eax
8010640a:	eb 15                	jmp    80106421 <sys_unlink+0x218>

bad:
  iunlockput(dp);
8010640c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640f:	89 04 24             	mov    %eax,(%esp)
80106412:	e8 0f b9 ff ff       	call   80101d26 <iunlockput>
  end_op();
80106417:	e8 31 d5 ff ff       	call   8010394d <end_op>
  return -1;
8010641c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106421:	c9                   	leave  
80106422:	c3                   	ret    

80106423 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80106423:	55                   	push   %ebp
80106424:	89 e5                	mov    %esp,%ebp
80106426:	83 ec 48             	sub    $0x48,%esp
80106429:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010642c:	8b 55 10             	mov    0x10(%ebp),%edx
8010642f:	8b 45 14             	mov    0x14(%ebp),%eax
80106432:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80106436:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
8010643a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010643e:	8d 45 de             	lea    -0x22(%ebp),%eax
80106441:	89 44 24 04          	mov    %eax,0x4(%esp)
80106445:	8b 45 08             	mov    0x8(%ebp),%eax
80106448:	89 04 24             	mov    %eax,(%esp)
8010644b:	e8 9a c3 ff ff       	call   801027ea <nameiparent>
80106450:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106453:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106457:	75 0a                	jne    80106463 <create+0x40>
    return 0;
80106459:	b8 00 00 00 00       	mov    $0x0,%eax
8010645e:	e9 79 01 00 00       	jmp    801065dc <create+0x1b9>
  ilock(dp);
80106463:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106466:	89 04 24             	mov    %eax,(%esp)
80106469:	e8 b9 b6 ff ff       	call   80101b27 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010646e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106471:	89 44 24 08          	mov    %eax,0x8(%esp)
80106475:	8d 45 de             	lea    -0x22(%ebp),%eax
80106478:	89 44 24 04          	mov    %eax,0x4(%esp)
8010647c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647f:	89 04 24             	mov    %eax,(%esp)
80106482:	e8 c0 be ff ff       	call   80102347 <dirlookup>
80106487:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010648a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010648e:	74 46                	je     801064d6 <create+0xb3>
    iunlockput(dp);
80106490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106493:	89 04 24             	mov    %eax,(%esp)
80106496:	e8 8b b8 ff ff       	call   80101d26 <iunlockput>
    ilock(ip);
8010649b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010649e:	89 04 24             	mov    %eax,(%esp)
801064a1:	e8 81 b6 ff ff       	call   80101b27 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801064a6:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801064ab:	75 14                	jne    801064c1 <create+0x9e>
801064ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064b0:	8b 40 50             	mov    0x50(%eax),%eax
801064b3:	66 83 f8 02          	cmp    $0x2,%ax
801064b7:	75 08                	jne    801064c1 <create+0x9e>
      return ip;
801064b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064bc:	e9 1b 01 00 00       	jmp    801065dc <create+0x1b9>
    iunlockput(ip);
801064c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c4:	89 04 24             	mov    %eax,(%esp)
801064c7:	e8 5a b8 ff ff       	call   80101d26 <iunlockput>
    return 0;
801064cc:	b8 00 00 00 00       	mov    $0x0,%eax
801064d1:	e9 06 01 00 00       	jmp    801065dc <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801064d6:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801064da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064dd:	8b 00                	mov    (%eax),%eax
801064df:	89 54 24 04          	mov    %edx,0x4(%esp)
801064e3:	89 04 24             	mov    %eax,(%esp)
801064e6:	e8 a7 b3 ff ff       	call   80101892 <ialloc>
801064eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801064ee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801064f2:	75 0c                	jne    80106500 <create+0xdd>
    panic("create: ialloc");
801064f4:	c7 04 24 fc a0 10 80 	movl   $0x8010a0fc,(%esp)
801064fb:	e8 54 a0 ff ff       	call   80100554 <panic>

  ilock(ip);
80106500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106503:	89 04 24             	mov    %eax,(%esp)
80106506:	e8 1c b6 ff ff       	call   80101b27 <ilock>
  ip->major = major;
8010650b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010650e:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106511:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80106515:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106518:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010651b:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
8010651f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106522:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106528:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010652b:	89 04 24             	mov    %eax,(%esp)
8010652e:	e8 31 b4 ff ff       	call   80101964 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80106533:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106538:	75 68                	jne    801065a2 <create+0x17f>
    dp->nlink++;  // for ".."
8010653a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010653d:	66 8b 40 56          	mov    0x56(%eax),%ax
80106541:	40                   	inc    %eax
80106542:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106545:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106549:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010654c:	89 04 24             	mov    %eax,(%esp)
8010654f:	e8 10 b4 ff ff       	call   80101964 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106554:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106557:	8b 40 04             	mov    0x4(%eax),%eax
8010655a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010655e:	c7 44 24 04 d6 a0 10 	movl   $0x8010a0d6,0x4(%esp)
80106565:	80 
80106566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106569:	89 04 24             	mov    %eax,(%esp)
8010656c:	e8 9c be ff ff       	call   8010240d <dirlink>
80106571:	85 c0                	test   %eax,%eax
80106573:	78 21                	js     80106596 <create+0x173>
80106575:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106578:	8b 40 04             	mov    0x4(%eax),%eax
8010657b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010657f:	c7 44 24 04 d8 a0 10 	movl   $0x8010a0d8,0x4(%esp)
80106586:	80 
80106587:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010658a:	89 04 24             	mov    %eax,(%esp)
8010658d:	e8 7b be ff ff       	call   8010240d <dirlink>
80106592:	85 c0                	test   %eax,%eax
80106594:	79 0c                	jns    801065a2 <create+0x17f>
      panic("create dots");
80106596:	c7 04 24 0b a1 10 80 	movl   $0x8010a10b,(%esp)
8010659d:	e8 b2 9f ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801065a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a5:	8b 40 04             	mov    0x4(%eax),%eax
801065a8:	89 44 24 08          	mov    %eax,0x8(%esp)
801065ac:	8d 45 de             	lea    -0x22(%ebp),%eax
801065af:	89 44 24 04          	mov    %eax,0x4(%esp)
801065b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065b6:	89 04 24             	mov    %eax,(%esp)
801065b9:	e8 4f be ff ff       	call   8010240d <dirlink>
801065be:	85 c0                	test   %eax,%eax
801065c0:	79 0c                	jns    801065ce <create+0x1ab>
    panic("create: dirlink");
801065c2:	c7 04 24 17 a1 10 80 	movl   $0x8010a117,(%esp)
801065c9:	e8 86 9f ff ff       	call   80100554 <panic>

  iunlockput(dp);
801065ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d1:	89 04 24             	mov    %eax,(%esp)
801065d4:	e8 4d b7 ff ff       	call   80101d26 <iunlockput>

  return ip;
801065d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801065dc:	c9                   	leave  
801065dd:	c3                   	ret    

801065de <sys_open>:

int
sys_open(void)
{
801065de:	55                   	push   %ebp
801065df:	89 e5                	mov    %esp,%ebp
801065e1:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801065e4:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801065eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065f2:	e8 a9 f6 ff ff       	call   80105ca0 <argstr>
801065f7:	85 c0                	test   %eax,%eax
801065f9:	78 17                	js     80106612 <sys_open+0x34>
801065fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801065fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106602:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106609:	e8 fb f5 ff ff       	call   80105c09 <argint>
8010660e:	85 c0                	test   %eax,%eax
80106610:	79 0a                	jns    8010661c <sys_open+0x3e>
    return -1;
80106612:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106617:	e9 64 01 00 00       	jmp    80106780 <sys_open+0x1a2>

  begin_op();
8010661c:	e8 aa d2 ff ff       	call   801038cb <begin_op>

  if(omode & O_CREATE){
80106621:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106624:	25 00 02 00 00       	and    $0x200,%eax
80106629:	85 c0                	test   %eax,%eax
8010662b:	74 3b                	je     80106668 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
8010662d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106630:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106637:	00 
80106638:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010663f:	00 
80106640:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
80106647:	00 
80106648:	89 04 24             	mov    %eax,(%esp)
8010664b:	e8 d3 fd ff ff       	call   80106423 <create>
80106650:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106653:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106657:	75 6a                	jne    801066c3 <sys_open+0xe5>
      end_op();
80106659:	e8 ef d2 ff ff       	call   8010394d <end_op>
      return -1;
8010665e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106663:	e9 18 01 00 00       	jmp    80106780 <sys_open+0x1a2>
    }
  } else {
    if((ip = namei(path)) == 0){
80106668:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010666b:	89 04 24             	mov    %eax,(%esp)
8010666e:	e8 55 c1 ff ff       	call   801027c8 <namei>
80106673:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106676:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010667a:	75 0f                	jne    8010668b <sys_open+0xad>
      end_op();
8010667c:	e8 cc d2 ff ff       	call   8010394d <end_op>
      return -1;
80106681:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106686:	e9 f5 00 00 00       	jmp    80106780 <sys_open+0x1a2>
    }
    ilock(ip);
8010668b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010668e:	89 04 24             	mov    %eax,(%esp)
80106691:	e8 91 b4 ff ff       	call   80101b27 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106699:	8b 40 50             	mov    0x50(%eax),%eax
8010669c:	66 83 f8 01          	cmp    $0x1,%ax
801066a0:	75 21                	jne    801066c3 <sys_open+0xe5>
801066a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066a5:	85 c0                	test   %eax,%eax
801066a7:	74 1a                	je     801066c3 <sys_open+0xe5>
      iunlockput(ip);
801066a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ac:	89 04 24             	mov    %eax,(%esp)
801066af:	e8 72 b6 ff ff       	call   80101d26 <iunlockput>
      end_op();
801066b4:	e8 94 d2 ff ff       	call   8010394d <end_op>
      return -1;
801066b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066be:	e9 bd 00 00 00       	jmp    80106780 <sys_open+0x1a2>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801066c3:	e8 3a aa ff ff       	call   80101102 <filealloc>
801066c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066cf:	74 14                	je     801066e5 <sys_open+0x107>
801066d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066d4:	89 04 24             	mov    %eax,(%esp)
801066d7:	e8 f8 f6 ff ff       	call   80105dd4 <fdalloc>
801066dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801066df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801066e3:	79 28                	jns    8010670d <sys_open+0x12f>
    if(f)
801066e5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066e9:	74 0b                	je     801066f6 <sys_open+0x118>
      fileclose(f);
801066eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ee:	89 04 24             	mov    %eax,(%esp)
801066f1:	e8 b4 aa ff ff       	call   801011aa <fileclose>
    iunlockput(ip);
801066f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f9:	89 04 24             	mov    %eax,(%esp)
801066fc:	e8 25 b6 ff ff       	call   80101d26 <iunlockput>
    end_op();
80106701:	e8 47 d2 ff ff       	call   8010394d <end_op>
    return -1;
80106706:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010670b:	eb 73                	jmp    80106780 <sys_open+0x1a2>
  }
  iunlock(ip);
8010670d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106710:	89 04 24             	mov    %eax,(%esp)
80106713:	e8 19 b5 ff ff       	call   80101c31 <iunlock>
  end_op();
80106718:	e8 30 d2 ff ff       	call   8010394d <end_op>

  f->type = FD_INODE;
8010671d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106720:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80106726:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106729:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010672c:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
8010672f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106732:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106739:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010673c:	83 e0 01             	and    $0x1,%eax
8010673f:	85 c0                	test   %eax,%eax
80106741:	0f 94 c0             	sete   %al
80106744:	88 c2                	mov    %al,%dl
80106746:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106749:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010674c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010674f:	83 e0 01             	and    $0x1,%eax
80106752:	85 c0                	test   %eax,%eax
80106754:	75 0a                	jne    80106760 <sys_open+0x182>
80106756:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106759:	83 e0 02             	and    $0x2,%eax
8010675c:	85 c0                	test   %eax,%eax
8010675e:	74 07                	je     80106767 <sys_open+0x189>
80106760:	b8 01 00 00 00       	mov    $0x1,%eax
80106765:	eb 05                	jmp    8010676c <sys_open+0x18e>
80106767:	b8 00 00 00 00       	mov    $0x0,%eax
8010676c:	88 c2                	mov    %al,%dl
8010676e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106771:	88 50 09             	mov    %dl,0x9(%eax)
  f->path = path;
80106774:	8b 55 e8             	mov    -0x18(%ebp),%edx
80106777:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010677a:	89 50 18             	mov    %edx,0x18(%eax)
  return fd;
8010677d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106780:	c9                   	leave  
80106781:	c3                   	ret    

80106782 <sys_mkdir>:

int
sys_mkdir(void)
{
80106782:	55                   	push   %ebp
80106783:	89 e5                	mov    %esp,%ebp
80106785:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106788:	e8 3e d1 ff ff       	call   801038cb <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010678d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106790:	89 44 24 04          	mov    %eax,0x4(%esp)
80106794:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010679b:	e8 00 f5 ff ff       	call   80105ca0 <argstr>
801067a0:	85 c0                	test   %eax,%eax
801067a2:	78 2c                	js     801067d0 <sys_mkdir+0x4e>
801067a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067a7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801067ae:	00 
801067af:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801067b6:	00 
801067b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801067be:	00 
801067bf:	89 04 24             	mov    %eax,(%esp)
801067c2:	e8 5c fc ff ff       	call   80106423 <create>
801067c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801067ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801067ce:	75 0c                	jne    801067dc <sys_mkdir+0x5a>
    end_op();
801067d0:	e8 78 d1 ff ff       	call   8010394d <end_op>
    return -1;
801067d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067da:	eb 15                	jmp    801067f1 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801067dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067df:	89 04 24             	mov    %eax,(%esp)
801067e2:	e8 3f b5 ff ff       	call   80101d26 <iunlockput>
  end_op();
801067e7:	e8 61 d1 ff ff       	call   8010394d <end_op>
  return 0;
801067ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801067f1:	c9                   	leave  
801067f2:	c3                   	ret    

801067f3 <sys_mknod>:

int
sys_mknod(void)
{
801067f3:	55                   	push   %ebp
801067f4:	89 e5                	mov    %esp,%ebp
801067f6:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801067f9:	e8 cd d0 ff ff       	call   801038cb <begin_op>
  if((argstr(0, &path)) < 0 ||
801067fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106801:	89 44 24 04          	mov    %eax,0x4(%esp)
80106805:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010680c:	e8 8f f4 ff ff       	call   80105ca0 <argstr>
80106811:	85 c0                	test   %eax,%eax
80106813:	78 5e                	js     80106873 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106815:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106818:	89 44 24 04          	mov    %eax,0x4(%esp)
8010681c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106823:	e8 e1 f3 ff ff       	call   80105c09 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106828:	85 c0                	test   %eax,%eax
8010682a:	78 47                	js     80106873 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
8010682c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010682f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106833:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010683a:	e8 ca f3 ff ff       	call   80105c09 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010683f:	85 c0                	test   %eax,%eax
80106841:	78 30                	js     80106873 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106843:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106846:	0f bf c8             	movswl %ax,%ecx
80106849:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010684c:	0f bf d0             	movswl %ax,%edx
8010684f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106852:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106856:	89 54 24 08          	mov    %edx,0x8(%esp)
8010685a:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106861:	00 
80106862:	89 04 24             	mov    %eax,(%esp)
80106865:	e8 b9 fb ff ff       	call   80106423 <create>
8010686a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010686d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106871:	75 0c                	jne    8010687f <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106873:	e8 d5 d0 ff ff       	call   8010394d <end_op>
    return -1;
80106878:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010687d:	eb 15                	jmp    80106894 <sys_mknod+0xa1>
  }
  iunlockput(ip);
8010687f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106882:	89 04 24             	mov    %eax,(%esp)
80106885:	e8 9c b4 ff ff       	call   80101d26 <iunlockput>
  end_op();
8010688a:	e8 be d0 ff ff       	call   8010394d <end_op>
  return 0;
8010688f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106894:	c9                   	leave  
80106895:	c3                   	ret    

80106896 <sys_chdir>:

int
sys_chdir(void)
{
80106896:	55                   	push   %ebp
80106897:	89 e5                	mov    %esp,%ebp
80106899:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010689c:	e8 2a dd ff ff       	call   801045cb <myproc>
801068a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801068a4:	e8 22 d0 ff ff       	call   801038cb <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801068a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801068b0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068b7:	e8 e4 f3 ff ff       	call   80105ca0 <argstr>
801068bc:	85 c0                	test   %eax,%eax
801068be:	78 14                	js     801068d4 <sys_chdir+0x3e>
801068c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801068c3:	89 04 24             	mov    %eax,(%esp)
801068c6:	e8 fd be ff ff       	call   801027c8 <namei>
801068cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801068ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801068d2:	75 0c                	jne    801068e0 <sys_chdir+0x4a>
    end_op();
801068d4:	e8 74 d0 ff ff       	call   8010394d <end_op>
    return -1;
801068d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068de:	eb 5a                	jmp    8010693a <sys_chdir+0xa4>
  }
  ilock(ip);
801068e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e3:	89 04 24             	mov    %eax,(%esp)
801068e6:	e8 3c b2 ff ff       	call   80101b27 <ilock>
  if(ip->type != T_DIR){
801068eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068ee:	8b 40 50             	mov    0x50(%eax),%eax
801068f1:	66 83 f8 01          	cmp    $0x1,%ax
801068f5:	74 17                	je     8010690e <sys_chdir+0x78>
    iunlockput(ip);
801068f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068fa:	89 04 24             	mov    %eax,(%esp)
801068fd:	e8 24 b4 ff ff       	call   80101d26 <iunlockput>
    end_op();
80106902:	e8 46 d0 ff ff       	call   8010394d <end_op>
    return -1;
80106907:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010690c:	eb 2c                	jmp    8010693a <sys_chdir+0xa4>
  }
  iunlock(ip);
8010690e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106911:	89 04 24             	mov    %eax,(%esp)
80106914:	e8 18 b3 ff ff       	call   80101c31 <iunlock>
  iput(curproc->cwd);
80106919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010691c:	8b 40 68             	mov    0x68(%eax),%eax
8010691f:	89 04 24             	mov    %eax,(%esp)
80106922:	e8 4e b3 ff ff       	call   80101c75 <iput>
  end_op();
80106927:	e8 21 d0 ff ff       	call   8010394d <end_op>
  curproc->cwd = ip;
8010692c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010692f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106932:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106935:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010693a:	c9                   	leave  
8010693b:	c3                   	ret    

8010693c <sys_exec>:

int
sys_exec(void)
{
8010693c:	55                   	push   %ebp
8010693d:	89 e5                	mov    %esp,%ebp
8010693f:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106945:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106948:	89 44 24 04          	mov    %eax,0x4(%esp)
8010694c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106953:	e8 48 f3 ff ff       	call   80105ca0 <argstr>
80106958:	85 c0                	test   %eax,%eax
8010695a:	78 1a                	js     80106976 <sys_exec+0x3a>
8010695c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106962:	89 44 24 04          	mov    %eax,0x4(%esp)
80106966:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010696d:	e8 97 f2 ff ff       	call   80105c09 <argint>
80106972:	85 c0                	test   %eax,%eax
80106974:	79 0a                	jns    80106980 <sys_exec+0x44>
    return -1;
80106976:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010697b:	e9 c7 00 00 00       	jmp    80106a47 <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106980:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106987:	00 
80106988:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010698f:	00 
80106990:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106996:	89 04 24             	mov    %eax,(%esp)
80106999:	e8 38 ef ff ff       	call   801058d6 <memset>
  for(i=0;; i++){
8010699e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801069a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069a8:	83 f8 1f             	cmp    $0x1f,%eax
801069ab:	76 0a                	jbe    801069b7 <sys_exec+0x7b>
      return -1;
801069ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069b2:	e9 90 00 00 00       	jmp    80106a47 <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801069b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ba:	c1 e0 02             	shl    $0x2,%eax
801069bd:	89 c2                	mov    %eax,%edx
801069bf:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801069c5:	01 c2                	add    %eax,%edx
801069c7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801069cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801069d1:	89 14 24             	mov    %edx,(%esp)
801069d4:	e8 8f f1 ff ff       	call   80105b68 <fetchint>
801069d9:	85 c0                	test   %eax,%eax
801069db:	79 07                	jns    801069e4 <sys_exec+0xa8>
      return -1;
801069dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069e2:	eb 63                	jmp    80106a47 <sys_exec+0x10b>
    if(uarg == 0){
801069e4:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801069ea:	85 c0                	test   %eax,%eax
801069ec:	75 26                	jne    80106a14 <sys_exec+0xd8>
      argv[i] = 0;
801069ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069f1:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801069f8:	00 00 00 00 
      break;
801069fc:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801069fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a00:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106a06:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a0a:	89 04 24             	mov    %eax,(%esp)
80106a0d:	e8 2e a2 ff ff       	call   80100c40 <exec>
80106a12:	eb 33                	jmp    80106a47 <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106a14:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106a1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a1d:	c1 e2 02             	shl    $0x2,%edx
80106a20:	01 c2                	add    %eax,%edx
80106a22:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106a28:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a2c:	89 04 24             	mov    %eax,(%esp)
80106a2f:	e8 73 f1 ff ff       	call   80105ba7 <fetchstr>
80106a34:	85 c0                	test   %eax,%eax
80106a36:	79 07                	jns    80106a3f <sys_exec+0x103>
      return -1;
80106a38:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a3d:	eb 08                	jmp    80106a47 <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106a3f:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106a42:	e9 5e ff ff ff       	jmp    801069a5 <sys_exec+0x69>
  return exec(path, argv);
}
80106a47:	c9                   	leave  
80106a48:	c3                   	ret    

80106a49 <sys_pipe>:

int
sys_pipe(void)
{
80106a49:	55                   	push   %ebp
80106a4a:	89 e5                	mov    %esp,%ebp
80106a4c:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106a4f:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106a56:	00 
80106a57:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a5e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a65:	e8 cc f1 ff ff       	call   80105c36 <argptr>
80106a6a:	85 c0                	test   %eax,%eax
80106a6c:	79 0a                	jns    80106a78 <sys_pipe+0x2f>
    return -1;
80106a6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a73:	e9 9a 00 00 00       	jmp    80106b12 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106a78:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106a7b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a7f:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106a82:	89 04 24             	mov    %eax,(%esp)
80106a85:	e8 96 d6 ff ff       	call   80104120 <pipealloc>
80106a8a:	85 c0                	test   %eax,%eax
80106a8c:	79 07                	jns    80106a95 <sys_pipe+0x4c>
    return -1;
80106a8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a93:	eb 7d                	jmp    80106b12 <sys_pipe+0xc9>
  fd0 = -1;
80106a95:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106a9c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106a9f:	89 04 24             	mov    %eax,(%esp)
80106aa2:	e8 2d f3 ff ff       	call   80105dd4 <fdalloc>
80106aa7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106aaa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106aae:	78 14                	js     80106ac4 <sys_pipe+0x7b>
80106ab0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ab3:	89 04 24             	mov    %eax,(%esp)
80106ab6:	e8 19 f3 ff ff       	call   80105dd4 <fdalloc>
80106abb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106abe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106ac2:	79 36                	jns    80106afa <sys_pipe+0xb1>
    if(fd0 >= 0)
80106ac4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ac8:	78 13                	js     80106add <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106aca:	e8 fc da ff ff       	call   801045cb <myproc>
80106acf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ad2:	83 c2 08             	add    $0x8,%edx
80106ad5:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106adc:	00 
    fileclose(rf);
80106add:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ae0:	89 04 24             	mov    %eax,(%esp)
80106ae3:	e8 c2 a6 ff ff       	call   801011aa <fileclose>
    fileclose(wf);
80106ae8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106aeb:	89 04 24             	mov    %eax,(%esp)
80106aee:	e8 b7 a6 ff ff       	call   801011aa <fileclose>
    return -1;
80106af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106af8:	eb 18                	jmp    80106b12 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106afa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106afd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b00:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106b02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106b05:	8d 50 04             	lea    0x4(%eax),%edx
80106b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b0b:	89 02                	mov    %eax,(%edx)
  return 0;
80106b0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b12:	c9                   	leave  
80106b13:	c3                   	ret    

80106b14 <sys_fork>:
#define NULL ((void*)0)


int
sys_fork(void)
{
80106b14:	55                   	push   %ebp
80106b15:	89 e5                	mov    %esp,%ebp
80106b17:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106b1a:	e8 ac da ff ff       	call   801045cb <myproc>
80106b1f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106b25:	83 c0 18             	add    $0x18,%eax
80106b28:	89 04 24             	mov    %eax,(%esp)
80106b2b:	e8 e7 28 00 00       	call   80109417 <find>
80106b30:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
80106b33:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b37:	78 51                	js     80106b8a <sys_fork+0x76>
    int before = get_curr_proc(x);
80106b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b3c:	89 04 24             	mov    %eax,(%esp)
80106b3f:	e8 2b 2a 00 00       	call   8010956f <get_curr_proc>
80106b44:	89 45 f0             	mov    %eax,-0x10(%ebp)
    set_curr_proc(1, x);
80106b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b4a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b55:	e8 f9 2c 00 00       	call   80109853 <set_curr_proc>
    int after = get_curr_proc(x);
80106b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b5d:	89 04 24             	mov    %eax,(%esp)
80106b60:	e8 0a 2a 00 00       	call   8010956f <get_curr_proc>
80106b65:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(after == before){
80106b68:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106b6b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80106b6e:	75 1a                	jne    80106b8a <sys_fork+0x76>
      cstop_container_helper(myproc()->cont);
80106b70:	e8 56 da ff ff       	call   801045cb <myproc>
80106b75:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106b7b:	89 04 24             	mov    %eax,(%esp)
80106b7e:	e8 d9 e6 ff ff       	call   8010525c <cstop_container_helper>
      return -1;
80106b83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b88:	eb 05                	jmp    80106b8f <sys_fork+0x7b>
    }
  }
  return fork();
80106b8a:	e8 55 dd ff ff       	call   801048e4 <fork>
}
80106b8f:	c9                   	leave  
80106b90:	c3                   	ret    

80106b91 <sys_exit>:

int
sys_exit(void)
{
80106b91:	55                   	push   %ebp
80106b92:	89 e5                	mov    %esp,%ebp
80106b94:	83 ec 28             	sub    $0x28,%esp
  int x = find(myproc()->cont->name);
80106b97:	e8 2f da ff ff       	call   801045cb <myproc>
80106b9c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106ba2:	83 c0 18             	add    $0x18,%eax
80106ba5:	89 04 24             	mov    %eax,(%esp)
80106ba8:	e8 6a 28 00 00       	call   80109417 <find>
80106bad:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(x >= 0){
80106bb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106bb4:	78 13                	js     80106bc9 <sys_exit+0x38>
    set_curr_proc(-1, x);
80106bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bbd:	c7 04 24 ff ff ff ff 	movl   $0xffffffff,(%esp)
80106bc4:	e8 8a 2c 00 00       	call   80109853 <set_curr_proc>
  }
  exit();
80106bc9:	e8 8e de ff ff       	call   80104a5c <exit>
  return 0;  // not reached
80106bce:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bd3:	c9                   	leave  
80106bd4:	c3                   	ret    

80106bd5 <sys_wait>:

int
sys_wait(void)
{
80106bd5:	55                   	push   %ebp
80106bd6:	89 e5                	mov    %esp,%ebp
80106bd8:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106bdb:	e8 c0 df ff ff       	call   80104ba0 <wait>
}
80106be0:	c9                   	leave  
80106be1:	c3                   	ret    

80106be2 <sys_kill>:

int
sys_kill(void)
{
80106be2:	55                   	push   %ebp
80106be3:	89 e5                	mov    %esp,%ebp
80106be5:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106be8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106beb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bf6:	e8 0e f0 ff ff       	call   80105c09 <argint>
80106bfb:	85 c0                	test   %eax,%eax
80106bfd:	79 07                	jns    80106c06 <sys_kill+0x24>
    return -1;
80106bff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c04:	eb 0b                	jmp    80106c11 <sys_kill+0x2f>
  return kill(pid);
80106c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c09:	89 04 24             	mov    %eax,(%esp)
80106c0c:	e8 14 e4 ff ff       	call   80105025 <kill>
}
80106c11:	c9                   	leave  
80106c12:	c3                   	ret    

80106c13 <sys_getpid>:

int
sys_getpid(void)
{
80106c13:	55                   	push   %ebp
80106c14:	89 e5                	mov    %esp,%ebp
80106c16:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106c19:	e8 ad d9 ff ff       	call   801045cb <myproc>
80106c1e:	8b 40 10             	mov    0x10(%eax),%eax
}
80106c21:	c9                   	leave  
80106c22:	c3                   	ret    

80106c23 <sys_sbrk>:

int
sys_sbrk(void)
{
80106c23:	55                   	push   %ebp
80106c24:	89 e5                	mov    %esp,%ebp
80106c26:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106c29:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c2c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c37:	e8 cd ef ff ff       	call   80105c09 <argint>
80106c3c:	85 c0                	test   %eax,%eax
80106c3e:	79 07                	jns    80106c47 <sys_sbrk+0x24>
    return -1;
80106c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c45:	eb 23                	jmp    80106c6a <sys_sbrk+0x47>
  addr = myproc()->sz;
80106c47:	e8 7f d9 ff ff       	call   801045cb <myproc>
80106c4c:	8b 00                	mov    (%eax),%eax
80106c4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c54:	89 04 24             	mov    %eax,(%esp)
80106c57:	e8 ea db ff ff       	call   80104846 <growproc>
80106c5c:	85 c0                	test   %eax,%eax
80106c5e:	79 07                	jns    80106c67 <sys_sbrk+0x44>
    return -1;
80106c60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c65:	eb 03                	jmp    80106c6a <sys_sbrk+0x47>
  return addr;
80106c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106c6a:	c9                   	leave  
80106c6b:	c3                   	ret    

80106c6c <sys_sleep>:

int
sys_sleep(void)
{
80106c6c:	55                   	push   %ebp
80106c6d:	89 e5                	mov    %esp,%ebp
80106c6f:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106c72:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c75:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c80:	e8 84 ef ff ff       	call   80105c09 <argint>
80106c85:	85 c0                	test   %eax,%eax
80106c87:	79 07                	jns    80106c90 <sys_sleep+0x24>
    return -1;
80106c89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c8e:	eb 6b                	jmp    80106cfb <sys_sleep+0x8f>
  acquire(&tickslock);
80106c90:	c7 04 24 c0 84 11 80 	movl   $0x801184c0,(%esp)
80106c97:	e8 d7 e9 ff ff       	call   80105673 <acquire>
  ticks0 = ticks;
80106c9c:	a1 00 8d 11 80       	mov    0x80118d00,%eax
80106ca1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106ca4:	eb 33                	jmp    80106cd9 <sys_sleep+0x6d>
    if(myproc()->killed){
80106ca6:	e8 20 d9 ff ff       	call   801045cb <myproc>
80106cab:	8b 40 24             	mov    0x24(%eax),%eax
80106cae:	85 c0                	test   %eax,%eax
80106cb0:	74 13                	je     80106cc5 <sys_sleep+0x59>
      release(&tickslock);
80106cb2:	c7 04 24 c0 84 11 80 	movl   $0x801184c0,(%esp)
80106cb9:	e8 1f ea ff ff       	call   801056dd <release>
      return -1;
80106cbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cc3:	eb 36                	jmp    80106cfb <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106cc5:	c7 44 24 04 c0 84 11 	movl   $0x801184c0,0x4(%esp)
80106ccc:	80 
80106ccd:	c7 04 24 00 8d 11 80 	movl   $0x80118d00,(%esp)
80106cd4:	e8 4a e2 ff ff       	call   80104f23 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106cd9:	a1 00 8d 11 80       	mov    0x80118d00,%eax
80106cde:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106ce1:	89 c2                	mov    %eax,%edx
80106ce3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ce6:	39 c2                	cmp    %eax,%edx
80106ce8:	72 bc                	jb     80106ca6 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106cea:	c7 04 24 c0 84 11 80 	movl   $0x801184c0,(%esp)
80106cf1:	e8 e7 e9 ff ff       	call   801056dd <release>
  return 0;
80106cf6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106cfb:	c9                   	leave  
80106cfc:	c3                   	ret    

80106cfd <sys_cstop>:

void sys_cstop(){
80106cfd:	55                   	push   %ebp
80106cfe:	89 e5                	mov    %esp,%ebp
80106d00:	53                   	push   %ebx
80106d01:	83 ec 24             	sub    $0x24,%esp

  char* name;
  argstr(0, &name);
80106d04:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d07:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d12:	e8 89 ef ff ff       	call   80105ca0 <argstr>

  if(myproc()->cont != NULL){
80106d17:	e8 af d8 ff ff       	call   801045cb <myproc>
80106d1c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106d22:	85 c0                	test   %eax,%eax
80106d24:	74 72                	je     80106d98 <sys_cstop+0x9b>
    struct container* cont = myproc()->cont;
80106d26:	e8 a0 d8 ff ff       	call   801045cb <myproc>
80106d2b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106d31:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(strlen(name) == strlen(cont->name) && strncmp(name, cont->name, strlen(name)) == 0){
80106d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d37:	89 04 24             	mov    %eax,(%esp)
80106d3a:	e8 ea ed ff ff       	call   80105b29 <strlen>
80106d3f:	89 c3                	mov    %eax,%ebx
80106d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d44:	83 c0 18             	add    $0x18,%eax
80106d47:	89 04 24             	mov    %eax,(%esp)
80106d4a:	e8 da ed ff ff       	call   80105b29 <strlen>
80106d4f:	39 c3                	cmp    %eax,%ebx
80106d51:	75 37                	jne    80106d8a <sys_cstop+0x8d>
80106d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d56:	89 04 24             	mov    %eax,(%esp)
80106d59:	e8 cb ed ff ff       	call   80105b29 <strlen>
80106d5e:	89 c2                	mov    %eax,%edx
80106d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d63:	8d 48 18             	lea    0x18(%eax),%ecx
80106d66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d69:	89 54 24 08          	mov    %edx,0x8(%esp)
80106d6d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80106d71:	89 04 24             	mov    %eax,(%esp)
80106d74:	e8 c5 ec ff ff       	call   80105a3e <strncmp>
80106d79:	85 c0                	test   %eax,%eax
80106d7b:	75 0d                	jne    80106d8a <sys_cstop+0x8d>
      cstop_container_helper(cont);
80106d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d80:	89 04 24             	mov    %eax,(%esp)
80106d83:	e8 d4 e4 ff ff       	call   8010525c <cstop_container_helper>
80106d88:	eb 19                	jmp    80106da3 <sys_cstop+0xa6>
      //stop the processes
    }
    else{
      cprintf("You are not authorized to do this.\n");
80106d8a:	c7 04 24 28 a1 10 80 	movl   $0x8010a128,(%esp)
80106d91:	e8 2b 96 ff ff       	call   801003c1 <cprintf>
80106d96:	eb 0b                	jmp    80106da3 <sys_cstop+0xa6>
    }
  }
  else{
    cstop_helper(name);
80106d98:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d9b:	89 04 24             	mov    %eax,(%esp)
80106d9e:	e8 20 e5 ff ff       	call   801052c3 <cstop_helper>
  }

  //kill the processes with name as the id

}
80106da3:	83 c4 24             	add    $0x24,%esp
80106da6:	5b                   	pop    %ebx
80106da7:	5d                   	pop    %ebp
80106da8:	c3                   	ret    

80106da9 <sys_set_root_inode>:

void sys_set_root_inode(void){
80106da9:	55                   	push   %ebp
80106daa:	89 e5                	mov    %esp,%ebp
80106dac:	83 ec 28             	sub    $0x28,%esp

  char* name;
  argstr(0,&name);
80106daf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106db2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106db6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106dbd:	e8 de ee ff ff       	call   80105ca0 <argstr>

  set_root_inode(name);
80106dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dc5:	89 04 24             	mov    %eax,(%esp)
80106dc8:	e8 ce 24 00 00       	call   8010929b <set_root_inode>
  cprintf("success\n");
80106dcd:	c7 04 24 4c a1 10 80 	movl   $0x8010a14c,(%esp)
80106dd4:	e8 e8 95 ff ff       	call   801003c1 <cprintf>

}
80106dd9:	c9                   	leave  
80106dda:	c3                   	ret    

80106ddb <sys_ps>:

void sys_ps(void){
80106ddb:	55                   	push   %ebp
80106ddc:	89 e5                	mov    %esp,%ebp
80106dde:	83 ec 28             	sub    $0x28,%esp

  struct container* cont = myproc()->cont;
80106de1:	e8 e5 d7 ff ff       	call   801045cb <myproc>
80106de6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80106dec:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80106def:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106df3:	75 07                	jne    80106dfc <sys_ps+0x21>
    procdump();
80106df5:	e8 0a e3 ff ff       	call   80105104 <procdump>
80106dfa:	eb 0e                	jmp    80106e0a <sys_ps+0x2f>
  }
  else{
    // cprintf("passing in %s as name for c_procdump.\n", cont->name);
    c_procdump(cont->name);
80106dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dff:	83 c0 18             	add    $0x18,%eax
80106e02:	89 04 24             	mov    %eax,(%esp)
80106e05:	e8 4f e5 ff ff       	call   80105359 <c_procdump>
  }
}
80106e0a:	c9                   	leave  
80106e0b:	c3                   	ret    

80106e0c <sys_container_init>:

void sys_container_init(){
80106e0c:	55                   	push   %ebp
80106e0d:	89 e5                	mov    %esp,%ebp
80106e0f:	83 ec 08             	sub    $0x8,%esp
  container_init();
80106e12:	e8 dd 2a 00 00       	call   801098f4 <container_init>
}
80106e17:	c9                   	leave  
80106e18:	c3                   	ret    

80106e19 <sys_is_full>:

int sys_is_full(void){
80106e19:	55                   	push   %ebp
80106e1a:	89 e5                	mov    %esp,%ebp
80106e1c:	83 ec 08             	sub    $0x8,%esp
  return is_full();
80106e1f:	e8 a3 25 00 00       	call   801093c7 <is_full>
}
80106e24:	c9                   	leave  
80106e25:	c3                   	ret    

80106e26 <sys_find>:

int sys_find(void){
80106e26:	55                   	push   %ebp
80106e27:	89 e5                	mov    %esp,%ebp
80106e29:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106e2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e2f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e3a:	e8 61 ee ff ff       	call   80105ca0 <argstr>

  return find(name);
80106e3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e42:	89 04 24             	mov    %eax,(%esp)
80106e45:	e8 cd 25 00 00       	call   80109417 <find>
}
80106e4a:	c9                   	leave  
80106e4b:	c3                   	ret    

80106e4c <sys_get_name>:

void sys_get_name(void){
80106e4c:	55                   	push   %ebp
80106e4d:	89 e5                	mov    %esp,%ebp
80106e4f:	83 ec 28             	sub    $0x28,%esp

  int vc_num;
  char* name;
  argint(0, &vc_num);
80106e52:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e55:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e60:	e8 a4 ed ff ff       	call   80105c09 <argint>
  argstr(1, &name);
80106e65:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e68:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e6c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e73:	e8 28 ee ff ff       	call   80105ca0 <argstr>

  get_name(vc_num, name);
80106e78:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e7e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106e82:	89 04 24             	mov    %eax,(%esp)
80106e85:	e8 52 24 00 00       	call   801092dc <get_name>
}
80106e8a:	c9                   	leave  
80106e8b:	c3                   	ret    

80106e8c <sys_get_max_proc>:

int sys_get_max_proc(void){
80106e8c:	55                   	push   %ebp
80106e8d:	89 e5                	mov    %esp,%ebp
80106e8f:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106e92:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e95:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e99:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ea0:	e8 64 ed ff ff       	call   80105c09 <argint>


  return get_max_proc(vc_num);  
80106ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea8:	89 04 24             	mov    %eax,(%esp)
80106eab:	e8 d7 25 00 00       	call   80109487 <get_max_proc>
}
80106eb0:	c9                   	leave  
80106eb1:	c3                   	ret    

80106eb2 <sys_get_max_mem>:

int sys_get_max_mem(void){
80106eb2:	55                   	push   %ebp
80106eb3:	89 e5                	mov    %esp,%ebp
80106eb5:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106eb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ebb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ebf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ec6:	e8 3e ed ff ff       	call   80105c09 <argint>


  return get_max_mem(vc_num);
80106ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ece:	89 04 24             	mov    %eax,(%esp)
80106ed1:	e8 19 26 00 00       	call   801094ef <get_max_mem>
}
80106ed6:	c9                   	leave  
80106ed7:	c3                   	ret    

80106ed8 <sys_get_max_disk>:

int sys_get_max_disk(void){
80106ed8:	55                   	push   %ebp
80106ed9:	89 e5                	mov    %esp,%ebp
80106edb:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106ede:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ee1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ee5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106eec:	e8 18 ed ff ff       	call   80105c09 <argint>


  return get_max_disk(vc_num);
80106ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef4:	89 04 24             	mov    %eax,(%esp)
80106ef7:	e8 33 26 00 00       	call   8010952f <get_max_disk>

}
80106efc:	c9                   	leave  
80106efd:	c3                   	ret    

80106efe <sys_get_curr_proc>:

int sys_get_curr_proc(void){
80106efe:	55                   	push   %ebp
80106eff:	89 e5                	mov    %esp,%ebp
80106f01:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106f04:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f07:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f12:	e8 f2 ec ff ff       	call   80105c09 <argint>


  return get_curr_proc(vc_num);
80106f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1a:	89 04 24             	mov    %eax,(%esp)
80106f1d:	e8 4d 26 00 00       	call   8010956f <get_curr_proc>
}
80106f22:	c9                   	leave  
80106f23:	c3                   	ret    

80106f24 <sys_get_curr_mem>:

int sys_get_curr_mem(void){
80106f24:	55                   	push   %ebp
80106f25:	89 e5                	mov    %esp,%ebp
80106f27:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106f2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f2d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f38:	e8 cc ec ff ff       	call   80105c09 <argint>


  return get_curr_mem(vc_num);
80106f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f40:	89 04 24             	mov    %eax,(%esp)
80106f43:	e8 67 26 00 00       	call   801095af <get_curr_mem>
}
80106f48:	c9                   	leave  
80106f49:	c3                   	ret    

80106f4a <sys_get_curr_disk>:

int sys_get_curr_disk(void){
80106f4a:	55                   	push   %ebp
80106f4b:	89 e5                	mov    %esp,%ebp
80106f4d:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(0, &vc_num);
80106f50:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f53:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f5e:	e8 a6 ec ff ff       	call   80105c09 <argint>


  return get_curr_disk(vc_num);
80106f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f66:	89 04 24             	mov    %eax,(%esp)
80106f69:	e8 81 26 00 00       	call   801095ef <get_curr_disk>
}
80106f6e:	c9                   	leave  
80106f6f:	c3                   	ret    

80106f70 <sys_set_name>:

void sys_set_name(void){
80106f70:	55                   	push   %ebp
80106f71:	89 e5                	mov    %esp,%ebp
80106f73:	83 ec 28             	sub    $0x28,%esp
  char* name;
  argstr(0, &name);
80106f76:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106f79:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106f84:	e8 17 ed ff ff       	call   80105ca0 <argstr>

  int vc_num;
  argint(1, &vc_num);
80106f89:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106f97:	e8 6d ec ff ff       	call   80105c09 <argint>

  // myproc()->cont = get_container(vc_num);
  // cprintf("succ");

  set_name(name, vc_num);
80106f9c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fa2:	89 54 24 04          	mov    %edx,0x4(%esp)
80106fa6:	89 04 24             	mov    %eax,(%esp)
80106fa9:	e8 81 26 00 00       	call   8010962f <set_name>
  //cprintf("Done setting name.\n");
}
80106fae:	c9                   	leave  
80106faf:	c3                   	ret    

80106fb0 <sys_cont_proc_set>:

void sys_cont_proc_set(void){
80106fb0:	55                   	push   %ebp
80106fb1:	89 e5                	mov    %esp,%ebp
80106fb3:	53                   	push   %ebx
80106fb4:	83 ec 24             	sub    $0x24,%esp

  int vc_num;
  argint(0, &vc_num);
80106fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fba:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fbe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fc5:	e8 3f ec ff ff       	call   80105c09 <argint>

  // cprintf("before getting container\n");

  //So I can get the name, but I can't get the corresponding container
  // cprintf("In sys call proc set, container name is %s.\n", get_container(vc_num)->name);
  myproc()->cont = get_container(vc_num);
80106fca:	e8 fc d5 ff ff       	call   801045cb <myproc>
80106fcf:	89 c3                	mov    %eax,%ebx
80106fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd4:	89 04 24             	mov    %eax,(%esp)
80106fd7:	e8 eb 24 00 00       	call   801094c7 <get_container>
80106fdc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
  // cprintf("MY proc container name = %s.\n", myproc()->cont->name);

  // cprintf("after getting container\n");
}
80106fe2:	83 c4 24             	add    $0x24,%esp
80106fe5:	5b                   	pop    %ebx
80106fe6:	5d                   	pop    %ebp
80106fe7:	c3                   	ret    

80106fe8 <sys_set_max_mem>:

void sys_set_max_mem(void){
80106fe8:	55                   	push   %ebp
80106fe9:	89 e5                	mov    %esp,%ebp
80106feb:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
80106fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106ff1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ff5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ffc:	e8 08 ec ff ff       	call   80105c09 <argint>

  int vc_num;
  argint(1, &vc_num);
80107001:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107004:	89 44 24 04          	mov    %eax,0x4(%esp)
80107008:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010700f:	e8 f5 eb ff ff       	call   80105c09 <argint>

  set_max_mem(mem, vc_num);
80107014:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107017:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010701e:	89 04 24             	mov    %eax,(%esp)
80107021:	e8 40 26 00 00       	call   80109666 <set_max_mem>
}
80107026:	c9                   	leave  
80107027:	c3                   	ret    

80107028 <sys_set_max_disk>:

void sys_set_max_disk(void){
80107028:	55                   	push   %ebp
80107029:	89 e5                	mov    %esp,%ebp
8010702b:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
8010702e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107031:	89 44 24 04          	mov    %eax,0x4(%esp)
80107035:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010703c:	e8 c8 eb ff ff       	call   80105c09 <argint>

  int vc_num;
  argint(1, &vc_num);
80107041:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107044:	89 44 24 04          	mov    %eax,0x4(%esp)
80107048:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010704f:	e8 b5 eb ff ff       	call   80105c09 <argint>

  set_max_disk(disk, vc_num);
80107054:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010705e:	89 04 24             	mov    %eax,(%esp)
80107061:	e8 25 26 00 00       	call   8010968b <set_max_disk>
}
80107066:	c9                   	leave  
80107067:	c3                   	ret    

80107068 <sys_set_max_proc>:

void sys_set_max_proc(void){
80107068:	55                   	push   %ebp
80107069:	89 e5                	mov    %esp,%ebp
8010706b:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
8010706e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107071:	89 44 24 04          	mov    %eax,0x4(%esp)
80107075:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010707c:	e8 88 eb ff ff       	call   80105c09 <argint>

  int vc_num;
  argint(1, &vc_num);
80107081:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107084:	89 44 24 04          	mov    %eax,0x4(%esp)
80107088:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010708f:	e8 75 eb ff ff       	call   80105c09 <argint>

  set_max_proc(proc, vc_num);
80107094:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010709e:	89 04 24             	mov    %eax,(%esp)
801070a1:	e8 0b 26 00 00       	call   801096b1 <set_max_proc>
}
801070a6:	c9                   	leave  
801070a7:	c3                   	ret    

801070a8 <sys_set_curr_mem>:

void sys_set_curr_mem(void){
801070a8:	55                   	push   %ebp
801070a9:	89 e5                	mov    %esp,%ebp
801070ab:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
801070ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801070b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801070bc:	e8 48 eb ff ff       	call   80105c09 <argint>

  int vc_num;
  argint(1, &vc_num);
801070c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801070c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801070c8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801070cf:	e8 35 eb ff ff       	call   80105c09 <argint>

  set_curr_mem(mem, vc_num);
801070d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801070d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070da:	89 54 24 04          	mov    %edx,0x4(%esp)
801070de:	89 04 24             	mov    %eax,(%esp)
801070e1:	e8 f1 25 00 00       	call   801096d7 <set_curr_mem>
}
801070e6:	c9                   	leave  
801070e7:	c3                   	ret    

801070e8 <sys_reduce_curr_mem>:

void sys_reduce_curr_mem(void){
801070e8:	55                   	push   %ebp
801070e9:	89 e5                	mov    %esp,%ebp
801070eb:	83 ec 28             	sub    $0x28,%esp
  int mem;
  argint(0, &mem);
801070ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
801070f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801070f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801070fc:	e8 08 eb ff ff       	call   80105c09 <argint>

  int vc_num;
  argint(1, &vc_num);
80107101:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107104:	89 44 24 04          	mov    %eax,0x4(%esp)
80107108:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010710f:	e8 f5 ea ff ff       	call   80105c09 <argint>

  set_curr_mem(mem, vc_num);
80107114:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010711a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010711e:	89 04 24             	mov    %eax,(%esp)
80107121:	e8 b1 25 00 00       	call   801096d7 <set_curr_mem>
}
80107126:	c9                   	leave  
80107127:	c3                   	ret    

80107128 <sys_set_curr_disk>:

void sys_set_curr_disk(void){
80107128:	55                   	push   %ebp
80107129:	89 e5                	mov    %esp,%ebp
8010712b:	83 ec 28             	sub    $0x28,%esp
  int disk;
  argint(0, &disk);
8010712e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107131:	89 44 24 04          	mov    %eax,0x4(%esp)
80107135:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010713c:	e8 c8 ea ff ff       	call   80105c09 <argint>

  int vc_num;
  argint(1, &vc_num);
80107141:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107144:	89 44 24 04          	mov    %eax,0x4(%esp)
80107148:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010714f:	e8 b5 ea ff ff       	call   80105c09 <argint>

  set_curr_disk(disk, vc_num);
80107154:	8b 55 f0             	mov    -0x10(%ebp),%edx
80107157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010715a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010715e:	89 04 24             	mov    %eax,(%esp)
80107161:	e8 46 26 00 00       	call   801097ac <set_curr_disk>
  cprintf("ehehehehhe");
80107166:	c7 04 24 55 a1 10 80 	movl   $0x8010a155,(%esp)
8010716d:	e8 4f 92 ff ff       	call   801003c1 <cprintf>
}
80107172:	c9                   	leave  
80107173:	c3                   	ret    

80107174 <sys_set_curr_proc>:

void sys_set_curr_proc(void){
80107174:	55                   	push   %ebp
80107175:	89 e5                	mov    %esp,%ebp
80107177:	83 ec 28             	sub    $0x28,%esp
  int proc;
  argint(0, &proc);
8010717a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010717d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107181:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107188:	e8 7c ea ff ff       	call   80105c09 <argint>

  int vc_num;
  argint(1, &vc_num);
8010718d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107190:	89 44 24 04          	mov    %eax,0x4(%esp)
80107194:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010719b:	e8 69 ea ff ff       	call   80105c09 <argint>

  set_curr_proc(proc, vc_num);
801071a0:	8b 55 f0             	mov    -0x10(%ebp),%edx
801071a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071a6:	89 54 24 04          	mov    %edx,0x4(%esp)
801071aa:	89 04 24             	mov    %eax,(%esp)
801071ad:	e8 a1 26 00 00       	call   80109853 <set_curr_proc>
}
801071b2:	c9                   	leave  
801071b3:	c3                   	ret    

801071b4 <sys_container_reset>:

void sys_container_reset(void){
801071b4:	55                   	push   %ebp
801071b5:	89 e5                	mov    %esp,%ebp
801071b7:	83 ec 28             	sub    $0x28,%esp
  int vc_num;
  argint(1, &vc_num);
801071ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071bd:	89 44 24 04          	mov    %eax,0x4(%esp)
801071c1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801071c8:	e8 3c ea ff ff       	call   80105c09 <argint>
  container_reset(vc_num);
801071cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d0:	89 04 24             	mov    %eax,(%esp)
801071d3:	e8 31 28 00 00       	call   80109a09 <container_reset>
}
801071d8:	c9                   	leave  
801071d9:	c3                   	ret    

801071da <sys_uptime>:
// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801071da:	55                   	push   %ebp
801071db:	89 e5                	mov    %esp,%ebp
801071dd:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
801071e0:	c7 04 24 c0 84 11 80 	movl   $0x801184c0,(%esp)
801071e7:	e8 87 e4 ff ff       	call   80105673 <acquire>
  xticks = ticks;
801071ec:	a1 00 8d 11 80       	mov    0x80118d00,%eax
801071f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801071f4:	c7 04 24 c0 84 11 80 	movl   $0x801184c0,(%esp)
801071fb:	e8 dd e4 ff ff       	call   801056dd <release>
  return xticks;
80107200:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107203:	c9                   	leave  
80107204:	c3                   	ret    

80107205 <sys_getticks>:

int
sys_getticks(void){
80107205:	55                   	push   %ebp
80107206:	89 e5                	mov    %esp,%ebp
80107208:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
8010720b:	e8 bb d3 ff ff       	call   801045cb <myproc>
80107210:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80107213:	c9                   	leave  
80107214:	c3                   	ret    

80107215 <sys_max_containers>:

int sys_max_containers(void){
80107215:	55                   	push   %ebp
80107216:	89 e5                	mov    %esp,%ebp
80107218:	83 ec 08             	sub    $0x8,%esp
  return max_containers();
8010721b:	e8 ca 26 00 00       	call   801098ea <max_containers>
}
80107220:	c9                   	leave  
80107221:	c3                   	ret    

80107222 <sys_df>:


void sys_df(void){
80107222:	55                   	push   %ebp
80107223:	89 e5                	mov    %esp,%ebp
80107225:	83 ec 58             	sub    $0x58,%esp
  struct container* cont = myproc()->cont;
80107228:	e8 9e d3 ff ff       	call   801045cb <myproc>
8010722d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80107233:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct superblock sb;
  readsb(1, &sb);
80107236:	8d 45 b8             	lea    -0x48(%ebp),%eax
80107239:	89 44 24 04          	mov    %eax,0x4(%esp)
8010723d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107244:	e8 77 a2 ff ff       	call   801014c0 <readsb>

  int used = 0;
80107249:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(cont == NULL){
80107250:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107254:	75 52                	jne    801072a8 <sys_df+0x86>
    int max = max_containers();
80107256:	e8 8f 26 00 00       	call   801098ea <max_containers>
8010725b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int i;
    for(i = 0; i < max; i++){
8010725e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80107265:	eb 1d                	jmp    80107284 <sys_df+0x62>
      used = used + (int)(get_curr_disk(i) / 1024);
80107267:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010726a:	89 04 24             	mov    %eax,(%esp)
8010726d:	e8 7d 23 00 00       	call   801095ef <get_curr_disk>
80107272:	85 c0                	test   %eax,%eax
80107274:	79 05                	jns    8010727b <sys_df+0x59>
80107276:	05 ff 03 00 00       	add    $0x3ff,%eax
8010727b:	c1 f8 0a             	sar    $0xa,%eax
8010727e:	01 45 f4             	add    %eax,-0xc(%ebp)

  int used = 0;
  if(cont == NULL){
    int max = max_containers();
    int i;
    for(i = 0; i < max; i++){
80107281:	ff 45 f0             	incl   -0x10(%ebp)
80107284:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107287:	3b 45 e8             	cmp    -0x18(%ebp),%eax
8010728a:	7c db                	jl     80107267 <sys_df+0x45>
      used = used + (int)(get_curr_disk(i) / 1024);
    }
    cprintf("~%d used out of %d available.\n", used, sb.nblocks);
8010728c:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010728f:	89 44 24 08          	mov    %eax,0x8(%esp)
80107293:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107296:	89 44 24 04          	mov    %eax,0x4(%esp)
8010729a:	c7 04 24 60 a1 10 80 	movl   $0x8010a160,(%esp)
801072a1:	e8 1b 91 ff ff       	call   801003c1 <cprintf>
801072a6:	eb 4d                	jmp    801072f5 <sys_df+0xd3>
  }
  else{
    int x = find(cont->name);
801072a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072ab:	83 c0 18             	add    $0x18,%eax
801072ae:	89 04 24             	mov    %eax,(%esp)
801072b1:	e8 61 21 00 00       	call   80109417 <find>
801072b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    int used = (int)(get_curr_disk(x) / 1024);
801072b9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801072bc:	89 04 24             	mov    %eax,(%esp)
801072bf:	e8 2b 23 00 00       	call   801095ef <get_curr_disk>
801072c4:	85 c0                	test   %eax,%eax
801072c6:	79 05                	jns    801072cd <sys_df+0xab>
801072c8:	05 ff 03 00 00       	add    $0x3ff,%eax
801072cd:	c1 f8 0a             	sar    $0xa,%eax
801072d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    cprintf("~%d used out of %d available.\n", used,  get_max_disk(x));
801072d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801072d6:	89 04 24             	mov    %eax,(%esp)
801072d9:	e8 51 22 00 00       	call   8010952f <get_max_disk>
801072de:	89 44 24 08          	mov    %eax,0x8(%esp)
801072e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801072e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801072e9:	c7 04 24 60 a1 10 80 	movl   $0x8010a160,(%esp)
801072f0:	e8 cc 90 ff ff       	call   801003c1 <cprintf>
  }
}
801072f5:	c9                   	leave  
801072f6:	c3                   	ret    

801072f7 <sys_pause>:

void
sys_pause(void){
801072f7:	55                   	push   %ebp
801072f8:	89 e5                	mov    %esp,%ebp
801072fa:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
801072fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107300:	89 44 24 04          	mov    %eax,0x4(%esp)
80107304:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010730b:	e8 90 e9 ff ff       	call   80105ca0 <argstr>
  pause(name);
80107310:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107313:	89 04 24             	mov    %eax,(%esp)
80107316:	e8 29 e1 ff ff       	call   80105444 <pause>
}
8010731b:	c9                   	leave  
8010731c:	c3                   	ret    

8010731d <sys_resume>:

void
sys_resume(void){
8010731d:	55                   	push   %ebp
8010731e:	89 e5                	mov    %esp,%ebp
80107320:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
80107323:	8d 45 f4             	lea    -0xc(%ebp),%eax
80107326:	89 44 24 04          	mov    %eax,0x4(%esp)
8010732a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107331:	e8 6a e9 ff ff       	call   80105ca0 <argstr>
  resume(name);
80107336:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107339:	89 04 24             	mov    %eax,(%esp)
8010733c:	e8 66 e1 ff ff       	call   801054a7 <resume>
}
80107341:	c9                   	leave  
80107342:	c3                   	ret    

80107343 <sys_tmem>:

int
sys_tmem(void){
80107343:	55                   	push   %ebp
80107344:	89 e5                	mov    %esp,%ebp
80107346:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
80107349:	e8 7d d2 ff ff       	call   801045cb <myproc>
8010734e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80107354:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80107357:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010735b:	75 07                	jne    80107364 <sys_tmem+0x21>
    return mem_usage();
8010735d:	e8 ba bc ff ff       	call   8010301c <mem_usage>
80107362:	eb 16                	jmp    8010737a <sys_tmem+0x37>
  }
  return get_curr_mem(find(cont->name));
80107364:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107367:	83 c0 18             	add    $0x18,%eax
8010736a:	89 04 24             	mov    %eax,(%esp)
8010736d:	e8 a5 20 00 00       	call   80109417 <find>
80107372:	89 04 24             	mov    %eax,(%esp)
80107375:	e8 35 22 00 00       	call   801095af <get_curr_mem>
}
8010737a:	c9                   	leave  
8010737b:	c3                   	ret    

8010737c <sys_amem>:

int
sys_amem(void){
8010737c:	55                   	push   %ebp
8010737d:	89 e5                	mov    %esp,%ebp
8010737f:	83 ec 28             	sub    $0x28,%esp
  struct container* cont = myproc()->cont;
80107382:	e8 44 d2 ff ff       	call   801045cb <myproc>
80107387:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010738d:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(cont == NULL){
80107390:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107394:	75 07                	jne    8010739d <sys_amem+0x21>
    return mem_avail();
80107396:	e8 8b bc ff ff       	call   80103026 <mem_avail>
8010739b:	eb 16                	jmp    801073b3 <sys_amem+0x37>
  }
  return get_max_mem(find(cont->name));
8010739d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073a0:	83 c0 18             	add    $0x18,%eax
801073a3:	89 04 24             	mov    %eax,(%esp)
801073a6:	e8 6c 20 00 00       	call   80109417 <find>
801073ab:	89 04 24             	mov    %eax,(%esp)
801073ae:	e8 3c 21 00 00       	call   801094ef <get_max_mem>
}
801073b3:	c9                   	leave  
801073b4:	c3                   	ret    

801073b5 <sys_c_ps>:

void sys_c_ps(void){
801073b5:	55                   	push   %ebp
801073b6:	89 e5                	mov    %esp,%ebp
801073b8:	83 ec 28             	sub    $0x28,%esp
  char *name;
  argstr(0, &name);
801073bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073be:	89 44 24 04          	mov    %eax,0x4(%esp)
801073c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801073c9:	e8 d2 e8 ff ff       	call   80105ca0 <argstr>
  c_procdump(name);
801073ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d1:	89 04 24             	mov    %eax,(%esp)
801073d4:	e8 80 df ff ff       	call   80105359 <c_procdump>
}
801073d9:	c9                   	leave  
801073da:	c3                   	ret    

801073db <sys_get_used>:

int sys_get_used(void){
801073db:	55                   	push   %ebp
801073dc:	89 e5                	mov    %esp,%ebp
801073de:	83 ec 28             	sub    $0x28,%esp
  int x; 
  argint(0, &x);
801073e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801073e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801073e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801073ef:	e8 15 e8 ff ff       	call   80105c09 <argint>
  return get_used(x);
801073f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073f7:	89 04 24             	mov    %eax,(%esp)
801073fa:	e8 46 1f 00 00       	call   80109345 <get_used>
}
801073ff:	c9                   	leave  
80107400:	c3                   	ret    
80107401:	00 00                	add    %al,(%eax)
	...

80107404 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80107404:	1e                   	push   %ds
  pushl %es
80107405:	06                   	push   %es
  pushl %fs
80107406:	0f a0                	push   %fs
  pushl %gs
80107408:	0f a8                	push   %gs
  pushal
8010740a:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
8010740b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010740f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107411:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80107413:	54                   	push   %esp
  call trap
80107414:	e8 c0 01 00 00       	call   801075d9 <trap>
  addl $4, %esp
80107419:	83 c4 04             	add    $0x4,%esp

8010741c <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010741c:	61                   	popa   
  popl %gs
8010741d:	0f a9                	pop    %gs
  popl %fs
8010741f:	0f a1                	pop    %fs
  popl %es
80107421:	07                   	pop    %es
  popl %ds
80107422:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80107423:	83 c4 08             	add    $0x8,%esp
  iret
80107426:	cf                   	iret   
	...

80107428 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107428:	55                   	push   %ebp
80107429:	89 e5                	mov    %esp,%ebp
8010742b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010742e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107431:	48                   	dec    %eax
80107432:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107436:	8b 45 08             	mov    0x8(%ebp),%eax
80107439:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010743d:	8b 45 08             	mov    0x8(%ebp),%eax
80107440:	c1 e8 10             	shr    $0x10,%eax
80107443:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107447:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010744a:	0f 01 18             	lidtl  (%eax)
}
8010744d:	c9                   	leave  
8010744e:	c3                   	ret    

8010744f <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010744f:	55                   	push   %ebp
80107450:	89 e5                	mov    %esp,%ebp
80107452:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107455:	0f 20 d0             	mov    %cr2,%eax
80107458:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010745b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010745e:	c9                   	leave  
8010745f:	c3                   	ret    

80107460 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107460:	55                   	push   %ebp
80107461:	89 e5                	mov    %esp,%ebp
80107463:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80107466:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010746d:	e9 b8 00 00 00       	jmp    8010752a <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80107472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107475:	8b 04 85 18 d1 10 80 	mov    -0x7fef2ee8(,%eax,4),%eax
8010747c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010747f:	66 89 04 d5 00 85 11 	mov    %ax,-0x7fee7b00(,%edx,8)
80107486:	80 
80107487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010748a:	66 c7 04 c5 02 85 11 	movw   $0x8,-0x7fee7afe(,%eax,8)
80107491:	80 08 00 
80107494:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107497:	8a 14 c5 04 85 11 80 	mov    -0x7fee7afc(,%eax,8),%dl
8010749e:	83 e2 e0             	and    $0xffffffe0,%edx
801074a1:	88 14 c5 04 85 11 80 	mov    %dl,-0x7fee7afc(,%eax,8)
801074a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ab:	8a 14 c5 04 85 11 80 	mov    -0x7fee7afc(,%eax,8),%dl
801074b2:	83 e2 1f             	and    $0x1f,%edx
801074b5:	88 14 c5 04 85 11 80 	mov    %dl,-0x7fee7afc(,%eax,8)
801074bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074bf:	8a 14 c5 05 85 11 80 	mov    -0x7fee7afb(,%eax,8),%dl
801074c6:	83 e2 f0             	and    $0xfffffff0,%edx
801074c9:	83 ca 0e             	or     $0xe,%edx
801074cc:	88 14 c5 05 85 11 80 	mov    %dl,-0x7fee7afb(,%eax,8)
801074d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074d6:	8a 14 c5 05 85 11 80 	mov    -0x7fee7afb(,%eax,8),%dl
801074dd:	83 e2 ef             	and    $0xffffffef,%edx
801074e0:	88 14 c5 05 85 11 80 	mov    %dl,-0x7fee7afb(,%eax,8)
801074e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ea:	8a 14 c5 05 85 11 80 	mov    -0x7fee7afb(,%eax,8),%dl
801074f1:	83 e2 9f             	and    $0xffffff9f,%edx
801074f4:	88 14 c5 05 85 11 80 	mov    %dl,-0x7fee7afb(,%eax,8)
801074fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074fe:	8a 14 c5 05 85 11 80 	mov    -0x7fee7afb(,%eax,8),%dl
80107505:	83 ca 80             	or     $0xffffff80,%edx
80107508:	88 14 c5 05 85 11 80 	mov    %dl,-0x7fee7afb(,%eax,8)
8010750f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107512:	8b 04 85 18 d1 10 80 	mov    -0x7fef2ee8(,%eax,4),%eax
80107519:	c1 e8 10             	shr    $0x10,%eax
8010751c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010751f:	66 89 04 d5 06 85 11 	mov    %ax,-0x7fee7afa(,%edx,8)
80107526:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107527:	ff 45 f4             	incl   -0xc(%ebp)
8010752a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107531:	0f 8e 3b ff ff ff    	jle    80107472 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107537:	a1 18 d2 10 80       	mov    0x8010d218,%eax
8010753c:	66 a3 00 87 11 80    	mov    %ax,0x80118700
80107542:	66 c7 05 02 87 11 80 	movw   $0x8,0x80118702
80107549:	08 00 
8010754b:	a0 04 87 11 80       	mov    0x80118704,%al
80107550:	83 e0 e0             	and    $0xffffffe0,%eax
80107553:	a2 04 87 11 80       	mov    %al,0x80118704
80107558:	a0 04 87 11 80       	mov    0x80118704,%al
8010755d:	83 e0 1f             	and    $0x1f,%eax
80107560:	a2 04 87 11 80       	mov    %al,0x80118704
80107565:	a0 05 87 11 80       	mov    0x80118705,%al
8010756a:	83 c8 0f             	or     $0xf,%eax
8010756d:	a2 05 87 11 80       	mov    %al,0x80118705
80107572:	a0 05 87 11 80       	mov    0x80118705,%al
80107577:	83 e0 ef             	and    $0xffffffef,%eax
8010757a:	a2 05 87 11 80       	mov    %al,0x80118705
8010757f:	a0 05 87 11 80       	mov    0x80118705,%al
80107584:	83 c8 60             	or     $0x60,%eax
80107587:	a2 05 87 11 80       	mov    %al,0x80118705
8010758c:	a0 05 87 11 80       	mov    0x80118705,%al
80107591:	83 c8 80             	or     $0xffffff80,%eax
80107594:	a2 05 87 11 80       	mov    %al,0x80118705
80107599:	a1 18 d2 10 80       	mov    0x8010d218,%eax
8010759e:	c1 e8 10             	shr    $0x10,%eax
801075a1:	66 a3 06 87 11 80    	mov    %ax,0x80118706

  initlock(&tickslock, "time");
801075a7:	c7 44 24 04 80 a1 10 	movl   $0x8010a180,0x4(%esp)
801075ae:	80 
801075af:	c7 04 24 c0 84 11 80 	movl   $0x801184c0,(%esp)
801075b6:	e8 97 e0 ff ff       	call   80105652 <initlock>
}
801075bb:	c9                   	leave  
801075bc:	c3                   	ret    

801075bd <idtinit>:

void
idtinit(void)
{
801075bd:	55                   	push   %ebp
801075be:	89 e5                	mov    %esp,%ebp
801075c0:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801075c3:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801075ca:	00 
801075cb:	c7 04 24 00 85 11 80 	movl   $0x80118500,(%esp)
801075d2:	e8 51 fe ff ff       	call   80107428 <lidt>
}
801075d7:	c9                   	leave  
801075d8:	c3                   	ret    

801075d9 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801075d9:	55                   	push   %ebp
801075da:	89 e5                	mov    %esp,%ebp
801075dc:	57                   	push   %edi
801075dd:	56                   	push   %esi
801075de:	53                   	push   %ebx
801075df:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
801075e2:	8b 45 08             	mov    0x8(%ebp),%eax
801075e5:	8b 40 30             	mov    0x30(%eax),%eax
801075e8:	83 f8 40             	cmp    $0x40,%eax
801075eb:	75 3c                	jne    80107629 <trap+0x50>
    if(myproc()->killed)
801075ed:	e8 d9 cf ff ff       	call   801045cb <myproc>
801075f2:	8b 40 24             	mov    0x24(%eax),%eax
801075f5:	85 c0                	test   %eax,%eax
801075f7:	74 05                	je     801075fe <trap+0x25>
      exit();
801075f9:	e8 5e d4 ff ff       	call   80104a5c <exit>
    myproc()->tf = tf;
801075fe:	e8 c8 cf ff ff       	call   801045cb <myproc>
80107603:	8b 55 08             	mov    0x8(%ebp),%edx
80107606:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107609:	e8 c9 e6 ff ff       	call   80105cd7 <syscall>
    if(myproc()->killed)
8010760e:	e8 b8 cf ff ff       	call   801045cb <myproc>
80107613:	8b 40 24             	mov    0x24(%eax),%eax
80107616:	85 c0                	test   %eax,%eax
80107618:	74 0a                	je     80107624 <trap+0x4b>
      exit();
8010761a:	e8 3d d4 ff ff       	call   80104a5c <exit>
    return;
8010761f:	e9 30 02 00 00       	jmp    80107854 <trap+0x27b>
80107624:	e9 2b 02 00 00       	jmp    80107854 <trap+0x27b>
  }

  switch(tf->trapno){
80107629:	8b 45 08             	mov    0x8(%ebp),%eax
8010762c:	8b 40 30             	mov    0x30(%eax),%eax
8010762f:	83 e8 20             	sub    $0x20,%eax
80107632:	83 f8 1f             	cmp    $0x1f,%eax
80107635:	0f 87 cb 00 00 00    	ja     80107706 <trap+0x12d>
8010763b:	8b 04 85 28 a2 10 80 	mov    -0x7fef5dd8(,%eax,4),%eax
80107642:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80107644:	e8 b9 ce ff ff       	call   80104502 <cpuid>
80107649:	85 c0                	test   %eax,%eax
8010764b:	75 2f                	jne    8010767c <trap+0xa3>
      acquire(&tickslock);
8010764d:	c7 04 24 c0 84 11 80 	movl   $0x801184c0,(%esp)
80107654:	e8 1a e0 ff ff       	call   80105673 <acquire>
      ticks++;
80107659:	a1 00 8d 11 80       	mov    0x80118d00,%eax
8010765e:	40                   	inc    %eax
8010765f:	a3 00 8d 11 80       	mov    %eax,0x80118d00
      wakeup(&ticks);
80107664:	c7 04 24 00 8d 11 80 	movl   $0x80118d00,(%esp)
8010766b:	e8 8a d9 ff ff       	call   80104ffa <wakeup>
      release(&tickslock);
80107670:	c7 04 24 c0 84 11 80 	movl   $0x801184c0,(%esp)
80107677:	e8 61 e0 ff ff       	call   801056dd <release>
    }
    p = myproc();
8010767c:	e8 4a cf ff ff       	call   801045cb <myproc>
80107681:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80107684:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80107688:	74 0f                	je     80107699 <trap+0xc0>
      p->ticks++;
8010768a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010768d:	8b 40 7c             	mov    0x7c(%eax),%eax
80107690:	8d 50 01             	lea    0x1(%eax),%edx
80107693:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107696:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80107699:	e8 05 bd ff ff       	call   801033a3 <lapiceoi>
    break;
8010769e:	e9 35 01 00 00       	jmp    801077d8 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801076a3:	e8 4a b4 ff ff       	call   80102af2 <ideintr>
    lapiceoi();
801076a8:	e8 f6 bc ff ff       	call   801033a3 <lapiceoi>
    break;
801076ad:	e9 26 01 00 00       	jmp    801077d8 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801076b2:	e8 03 bb ff ff       	call   801031ba <kbdintr>
    lapiceoi();
801076b7:	e8 e7 bc ff ff       	call   801033a3 <lapiceoi>
    break;
801076bc:	e9 17 01 00 00       	jmp    801077d8 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801076c1:	e8 6f 03 00 00       	call   80107a35 <uartintr>
    lapiceoi();
801076c6:	e8 d8 bc ff ff       	call   801033a3 <lapiceoi>
    break;
801076cb:	e9 08 01 00 00       	jmp    801077d8 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801076d0:	8b 45 08             	mov    0x8(%ebp),%eax
801076d3:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801076d6:	8b 45 08             	mov    0x8(%ebp),%eax
801076d9:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801076dc:	0f b7 d8             	movzwl %ax,%ebx
801076df:	e8 1e ce ff ff       	call   80104502 <cpuid>
801076e4:	89 74 24 0c          	mov    %esi,0xc(%esp)
801076e8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801076ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801076f0:	c7 04 24 88 a1 10 80 	movl   $0x8010a188,(%esp)
801076f7:	e8 c5 8c ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
801076fc:	e8 a2 bc ff ff       	call   801033a3 <lapiceoi>
    break;
80107701:	e9 d2 00 00 00       	jmp    801077d8 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80107706:	e8 c0 ce ff ff       	call   801045cb <myproc>
8010770b:	85 c0                	test   %eax,%eax
8010770d:	74 10                	je     8010771f <trap+0x146>
8010770f:	8b 45 08             	mov    0x8(%ebp),%eax
80107712:	8b 40 3c             	mov    0x3c(%eax),%eax
80107715:	0f b7 c0             	movzwl %ax,%eax
80107718:	83 e0 03             	and    $0x3,%eax
8010771b:	85 c0                	test   %eax,%eax
8010771d:	75 40                	jne    8010775f <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010771f:	e8 2b fd ff ff       	call   8010744f <rcr2>
80107724:	89 c3                	mov    %eax,%ebx
80107726:	8b 45 08             	mov    0x8(%ebp),%eax
80107729:	8b 70 38             	mov    0x38(%eax),%esi
8010772c:	e8 d1 cd ff ff       	call   80104502 <cpuid>
80107731:	8b 55 08             	mov    0x8(%ebp),%edx
80107734:	8b 52 30             	mov    0x30(%edx),%edx
80107737:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010773b:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010773f:	89 44 24 08          	mov    %eax,0x8(%esp)
80107743:	89 54 24 04          	mov    %edx,0x4(%esp)
80107747:	c7 04 24 ac a1 10 80 	movl   $0x8010a1ac,(%esp)
8010774e:	e8 6e 8c ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80107753:	c7 04 24 de a1 10 80 	movl   $0x8010a1de,(%esp)
8010775a:	e8 f5 8d ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010775f:	e8 eb fc ff ff       	call   8010744f <rcr2>
80107764:	89 c6                	mov    %eax,%esi
80107766:	8b 45 08             	mov    0x8(%ebp),%eax
80107769:	8b 40 38             	mov    0x38(%eax),%eax
8010776c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010776f:	e8 8e cd ff ff       	call   80104502 <cpuid>
80107774:	89 c3                	mov    %eax,%ebx
80107776:	8b 45 08             	mov    0x8(%ebp),%eax
80107779:	8b 78 34             	mov    0x34(%eax),%edi
8010777c:	89 7d d0             	mov    %edi,-0x30(%ebp)
8010777f:	8b 45 08             	mov    0x8(%ebp),%eax
80107782:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80107785:	e8 41 ce ff ff       	call   801045cb <myproc>
8010778a:	8d 50 6c             	lea    0x6c(%eax),%edx
8010778d:	89 55 cc             	mov    %edx,-0x34(%ebp)
80107790:	e8 36 ce ff ff       	call   801045cb <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107795:	8b 40 10             	mov    0x10(%eax),%eax
80107798:	89 74 24 1c          	mov    %esi,0x1c(%esp)
8010779c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
8010779f:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801077a3:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801077a7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801077aa:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801077ae:	89 7c 24 0c          	mov    %edi,0xc(%esp)
801077b2:	8b 55 cc             	mov    -0x34(%ebp),%edx
801077b5:	89 54 24 08          	mov    %edx,0x8(%esp)
801077b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801077bd:	c7 04 24 e4 a1 10 80 	movl   $0x8010a1e4,(%esp)
801077c4:	e8 f8 8b ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801077c9:	e8 fd cd ff ff       	call   801045cb <myproc>
801077ce:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801077d5:	eb 01                	jmp    801077d8 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801077d7:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801077d8:	e8 ee cd ff ff       	call   801045cb <myproc>
801077dd:	85 c0                	test   %eax,%eax
801077df:	74 22                	je     80107803 <trap+0x22a>
801077e1:	e8 e5 cd ff ff       	call   801045cb <myproc>
801077e6:	8b 40 24             	mov    0x24(%eax),%eax
801077e9:	85 c0                	test   %eax,%eax
801077eb:	74 16                	je     80107803 <trap+0x22a>
801077ed:	8b 45 08             	mov    0x8(%ebp),%eax
801077f0:	8b 40 3c             	mov    0x3c(%eax),%eax
801077f3:	0f b7 c0             	movzwl %ax,%eax
801077f6:	83 e0 03             	and    $0x3,%eax
801077f9:	83 f8 03             	cmp    $0x3,%eax
801077fc:	75 05                	jne    80107803 <trap+0x22a>
    exit();
801077fe:	e8 59 d2 ff ff       	call   80104a5c <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107803:	e8 c3 cd ff ff       	call   801045cb <myproc>
80107808:	85 c0                	test   %eax,%eax
8010780a:	74 1d                	je     80107829 <trap+0x250>
8010780c:	e8 ba cd ff ff       	call   801045cb <myproc>
80107811:	8b 40 0c             	mov    0xc(%eax),%eax
80107814:	83 f8 04             	cmp    $0x4,%eax
80107817:	75 10                	jne    80107829 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80107819:	8b 45 08             	mov    0x8(%ebp),%eax
8010781c:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010781f:	83 f8 20             	cmp    $0x20,%eax
80107822:	75 05                	jne    80107829 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80107824:	e8 8a d6 ff ff       	call   80104eb3 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107829:	e8 9d cd ff ff       	call   801045cb <myproc>
8010782e:	85 c0                	test   %eax,%eax
80107830:	74 22                	je     80107854 <trap+0x27b>
80107832:	e8 94 cd ff ff       	call   801045cb <myproc>
80107837:	8b 40 24             	mov    0x24(%eax),%eax
8010783a:	85 c0                	test   %eax,%eax
8010783c:	74 16                	je     80107854 <trap+0x27b>
8010783e:	8b 45 08             	mov    0x8(%ebp),%eax
80107841:	8b 40 3c             	mov    0x3c(%eax),%eax
80107844:	0f b7 c0             	movzwl %ax,%eax
80107847:	83 e0 03             	and    $0x3,%eax
8010784a:	83 f8 03             	cmp    $0x3,%eax
8010784d:	75 05                	jne    80107854 <trap+0x27b>
    exit();
8010784f:	e8 08 d2 ff ff       	call   80104a5c <exit>
}
80107854:	83 c4 4c             	add    $0x4c,%esp
80107857:	5b                   	pop    %ebx
80107858:	5e                   	pop    %esi
80107859:	5f                   	pop    %edi
8010785a:	5d                   	pop    %ebp
8010785b:	c3                   	ret    

8010785c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010785c:	55                   	push   %ebp
8010785d:	89 e5                	mov    %esp,%ebp
8010785f:	83 ec 14             	sub    $0x14,%esp
80107862:	8b 45 08             	mov    0x8(%ebp),%eax
80107865:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107869:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010786c:	89 c2                	mov    %eax,%edx
8010786e:	ec                   	in     (%dx),%al
8010786f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107872:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80107875:	c9                   	leave  
80107876:	c3                   	ret    

80107877 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107877:	55                   	push   %ebp
80107878:	89 e5                	mov    %esp,%ebp
8010787a:	83 ec 08             	sub    $0x8,%esp
8010787d:	8b 45 08             	mov    0x8(%ebp),%eax
80107880:	8b 55 0c             	mov    0xc(%ebp),%edx
80107883:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107887:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010788a:	8a 45 f8             	mov    -0x8(%ebp),%al
8010788d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80107890:	ee                   	out    %al,(%dx)
}
80107891:	c9                   	leave  
80107892:	c3                   	ret    

80107893 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80107893:	55                   	push   %ebp
80107894:	89 e5                	mov    %esp,%ebp
80107896:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107899:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801078a0:	00 
801078a1:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801078a8:	e8 ca ff ff ff       	call   80107877 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801078ad:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801078b4:	00 
801078b5:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801078bc:	e8 b6 ff ff ff       	call   80107877 <outb>
  outb(COM1+0, 115200/9600);
801078c1:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801078c8:	00 
801078c9:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801078d0:	e8 a2 ff ff ff       	call   80107877 <outb>
  outb(COM1+1, 0);
801078d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801078dc:	00 
801078dd:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801078e4:	e8 8e ff ff ff       	call   80107877 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801078e9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801078f0:	00 
801078f1:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801078f8:	e8 7a ff ff ff       	call   80107877 <outb>
  outb(COM1+4, 0);
801078fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107904:	00 
80107905:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
8010790c:	e8 66 ff ff ff       	call   80107877 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107911:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107918:	00 
80107919:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107920:	e8 52 ff ff ff       	call   80107877 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107925:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010792c:	e8 2b ff ff ff       	call   8010785c <inb>
80107931:	3c ff                	cmp    $0xff,%al
80107933:	75 02                	jne    80107937 <uartinit+0xa4>
    return;
80107935:	eb 5b                	jmp    80107992 <uartinit+0xff>
  uart = 1;
80107937:	c7 05 24 d9 10 80 01 	movl   $0x1,0x8010d924
8010793e:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107941:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107948:	e8 0f ff ff ff       	call   8010785c <inb>
  inb(COM1+0);
8010794d:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107954:	e8 03 ff ff ff       	call   8010785c <inb>
  ioapicenable(IRQ_COM1, 0);
80107959:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107960:	00 
80107961:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107968:	e8 fa b3 ff ff       	call   80102d67 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010796d:	c7 45 f4 a8 a2 10 80 	movl   $0x8010a2a8,-0xc(%ebp)
80107974:	eb 13                	jmp    80107989 <uartinit+0xf6>
    uartputc(*p);
80107976:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107979:	8a 00                	mov    (%eax),%al
8010797b:	0f be c0             	movsbl %al,%eax
8010797e:	89 04 24             	mov    %eax,(%esp)
80107981:	e8 0e 00 00 00       	call   80107994 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107986:	ff 45 f4             	incl   -0xc(%ebp)
80107989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798c:	8a 00                	mov    (%eax),%al
8010798e:	84 c0                	test   %al,%al
80107990:	75 e4                	jne    80107976 <uartinit+0xe3>
    uartputc(*p);
}
80107992:	c9                   	leave  
80107993:	c3                   	ret    

80107994 <uartputc>:

void
uartputc(int c)
{
80107994:	55                   	push   %ebp
80107995:	89 e5                	mov    %esp,%ebp
80107997:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
8010799a:	a1 24 d9 10 80       	mov    0x8010d924,%eax
8010799f:	85 c0                	test   %eax,%eax
801079a1:	75 02                	jne    801079a5 <uartputc+0x11>
    return;
801079a3:	eb 4a                	jmp    801079ef <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801079a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079ac:	eb 0f                	jmp    801079bd <uartputc+0x29>
    microdelay(10);
801079ae:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801079b5:	e8 0e ba ff ff       	call   801033c8 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801079ba:	ff 45 f4             	incl   -0xc(%ebp)
801079bd:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801079c1:	7f 16                	jg     801079d9 <uartputc+0x45>
801079c3:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801079ca:	e8 8d fe ff ff       	call   8010785c <inb>
801079cf:	0f b6 c0             	movzbl %al,%eax
801079d2:	83 e0 20             	and    $0x20,%eax
801079d5:	85 c0                	test   %eax,%eax
801079d7:	74 d5                	je     801079ae <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
801079d9:	8b 45 08             	mov    0x8(%ebp),%eax
801079dc:	0f b6 c0             	movzbl %al,%eax
801079df:	89 44 24 04          	mov    %eax,0x4(%esp)
801079e3:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801079ea:	e8 88 fe ff ff       	call   80107877 <outb>
}
801079ef:	c9                   	leave  
801079f0:	c3                   	ret    

801079f1 <uartgetc>:

static int
uartgetc(void)
{
801079f1:	55                   	push   %ebp
801079f2:	89 e5                	mov    %esp,%ebp
801079f4:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801079f7:	a1 24 d9 10 80       	mov    0x8010d924,%eax
801079fc:	85 c0                	test   %eax,%eax
801079fe:	75 07                	jne    80107a07 <uartgetc+0x16>
    return -1;
80107a00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a05:	eb 2c                	jmp    80107a33 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107a07:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107a0e:	e8 49 fe ff ff       	call   8010785c <inb>
80107a13:	0f b6 c0             	movzbl %al,%eax
80107a16:	83 e0 01             	and    $0x1,%eax
80107a19:	85 c0                	test   %eax,%eax
80107a1b:	75 07                	jne    80107a24 <uartgetc+0x33>
    return -1;
80107a1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107a22:	eb 0f                	jmp    80107a33 <uartgetc+0x42>
  return inb(COM1+0);
80107a24:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107a2b:	e8 2c fe ff ff       	call   8010785c <inb>
80107a30:	0f b6 c0             	movzbl %al,%eax
}
80107a33:	c9                   	leave  
80107a34:	c3                   	ret    

80107a35 <uartintr>:

void
uartintr(void)
{
80107a35:	55                   	push   %ebp
80107a36:	89 e5                	mov    %esp,%ebp
80107a38:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107a3b:	c7 04 24 f1 79 10 80 	movl   $0x801079f1,(%esp)
80107a42:	e8 ae 8d ff ff       	call   801007f5 <consoleintr>
}
80107a47:	c9                   	leave  
80107a48:	c3                   	ret    
80107a49:	00 00                	add    %al,(%eax)
	...

80107a4c <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107a4c:	6a 00                	push   $0x0
  pushl $0
80107a4e:	6a 00                	push   $0x0
  jmp alltraps
80107a50:	e9 af f9 ff ff       	jmp    80107404 <alltraps>

80107a55 <vector1>:
.globl vector1
vector1:
  pushl $0
80107a55:	6a 00                	push   $0x0
  pushl $1
80107a57:	6a 01                	push   $0x1
  jmp alltraps
80107a59:	e9 a6 f9 ff ff       	jmp    80107404 <alltraps>

80107a5e <vector2>:
.globl vector2
vector2:
  pushl $0
80107a5e:	6a 00                	push   $0x0
  pushl $2
80107a60:	6a 02                	push   $0x2
  jmp alltraps
80107a62:	e9 9d f9 ff ff       	jmp    80107404 <alltraps>

80107a67 <vector3>:
.globl vector3
vector3:
  pushl $0
80107a67:	6a 00                	push   $0x0
  pushl $3
80107a69:	6a 03                	push   $0x3
  jmp alltraps
80107a6b:	e9 94 f9 ff ff       	jmp    80107404 <alltraps>

80107a70 <vector4>:
.globl vector4
vector4:
  pushl $0
80107a70:	6a 00                	push   $0x0
  pushl $4
80107a72:	6a 04                	push   $0x4
  jmp alltraps
80107a74:	e9 8b f9 ff ff       	jmp    80107404 <alltraps>

80107a79 <vector5>:
.globl vector5
vector5:
  pushl $0
80107a79:	6a 00                	push   $0x0
  pushl $5
80107a7b:	6a 05                	push   $0x5
  jmp alltraps
80107a7d:	e9 82 f9 ff ff       	jmp    80107404 <alltraps>

80107a82 <vector6>:
.globl vector6
vector6:
  pushl $0
80107a82:	6a 00                	push   $0x0
  pushl $6
80107a84:	6a 06                	push   $0x6
  jmp alltraps
80107a86:	e9 79 f9 ff ff       	jmp    80107404 <alltraps>

80107a8b <vector7>:
.globl vector7
vector7:
  pushl $0
80107a8b:	6a 00                	push   $0x0
  pushl $7
80107a8d:	6a 07                	push   $0x7
  jmp alltraps
80107a8f:	e9 70 f9 ff ff       	jmp    80107404 <alltraps>

80107a94 <vector8>:
.globl vector8
vector8:
  pushl $8
80107a94:	6a 08                	push   $0x8
  jmp alltraps
80107a96:	e9 69 f9 ff ff       	jmp    80107404 <alltraps>

80107a9b <vector9>:
.globl vector9
vector9:
  pushl $0
80107a9b:	6a 00                	push   $0x0
  pushl $9
80107a9d:	6a 09                	push   $0x9
  jmp alltraps
80107a9f:	e9 60 f9 ff ff       	jmp    80107404 <alltraps>

80107aa4 <vector10>:
.globl vector10
vector10:
  pushl $10
80107aa4:	6a 0a                	push   $0xa
  jmp alltraps
80107aa6:	e9 59 f9 ff ff       	jmp    80107404 <alltraps>

80107aab <vector11>:
.globl vector11
vector11:
  pushl $11
80107aab:	6a 0b                	push   $0xb
  jmp alltraps
80107aad:	e9 52 f9 ff ff       	jmp    80107404 <alltraps>

80107ab2 <vector12>:
.globl vector12
vector12:
  pushl $12
80107ab2:	6a 0c                	push   $0xc
  jmp alltraps
80107ab4:	e9 4b f9 ff ff       	jmp    80107404 <alltraps>

80107ab9 <vector13>:
.globl vector13
vector13:
  pushl $13
80107ab9:	6a 0d                	push   $0xd
  jmp alltraps
80107abb:	e9 44 f9 ff ff       	jmp    80107404 <alltraps>

80107ac0 <vector14>:
.globl vector14
vector14:
  pushl $14
80107ac0:	6a 0e                	push   $0xe
  jmp alltraps
80107ac2:	e9 3d f9 ff ff       	jmp    80107404 <alltraps>

80107ac7 <vector15>:
.globl vector15
vector15:
  pushl $0
80107ac7:	6a 00                	push   $0x0
  pushl $15
80107ac9:	6a 0f                	push   $0xf
  jmp alltraps
80107acb:	e9 34 f9 ff ff       	jmp    80107404 <alltraps>

80107ad0 <vector16>:
.globl vector16
vector16:
  pushl $0
80107ad0:	6a 00                	push   $0x0
  pushl $16
80107ad2:	6a 10                	push   $0x10
  jmp alltraps
80107ad4:	e9 2b f9 ff ff       	jmp    80107404 <alltraps>

80107ad9 <vector17>:
.globl vector17
vector17:
  pushl $17
80107ad9:	6a 11                	push   $0x11
  jmp alltraps
80107adb:	e9 24 f9 ff ff       	jmp    80107404 <alltraps>

80107ae0 <vector18>:
.globl vector18
vector18:
  pushl $0
80107ae0:	6a 00                	push   $0x0
  pushl $18
80107ae2:	6a 12                	push   $0x12
  jmp alltraps
80107ae4:	e9 1b f9 ff ff       	jmp    80107404 <alltraps>

80107ae9 <vector19>:
.globl vector19
vector19:
  pushl $0
80107ae9:	6a 00                	push   $0x0
  pushl $19
80107aeb:	6a 13                	push   $0x13
  jmp alltraps
80107aed:	e9 12 f9 ff ff       	jmp    80107404 <alltraps>

80107af2 <vector20>:
.globl vector20
vector20:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $20
80107af4:	6a 14                	push   $0x14
  jmp alltraps
80107af6:	e9 09 f9 ff ff       	jmp    80107404 <alltraps>

80107afb <vector21>:
.globl vector21
vector21:
  pushl $0
80107afb:	6a 00                	push   $0x0
  pushl $21
80107afd:	6a 15                	push   $0x15
  jmp alltraps
80107aff:	e9 00 f9 ff ff       	jmp    80107404 <alltraps>

80107b04 <vector22>:
.globl vector22
vector22:
  pushl $0
80107b04:	6a 00                	push   $0x0
  pushl $22
80107b06:	6a 16                	push   $0x16
  jmp alltraps
80107b08:	e9 f7 f8 ff ff       	jmp    80107404 <alltraps>

80107b0d <vector23>:
.globl vector23
vector23:
  pushl $0
80107b0d:	6a 00                	push   $0x0
  pushl $23
80107b0f:	6a 17                	push   $0x17
  jmp alltraps
80107b11:	e9 ee f8 ff ff       	jmp    80107404 <alltraps>

80107b16 <vector24>:
.globl vector24
vector24:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $24
80107b18:	6a 18                	push   $0x18
  jmp alltraps
80107b1a:	e9 e5 f8 ff ff       	jmp    80107404 <alltraps>

80107b1f <vector25>:
.globl vector25
vector25:
  pushl $0
80107b1f:	6a 00                	push   $0x0
  pushl $25
80107b21:	6a 19                	push   $0x19
  jmp alltraps
80107b23:	e9 dc f8 ff ff       	jmp    80107404 <alltraps>

80107b28 <vector26>:
.globl vector26
vector26:
  pushl $0
80107b28:	6a 00                	push   $0x0
  pushl $26
80107b2a:	6a 1a                	push   $0x1a
  jmp alltraps
80107b2c:	e9 d3 f8 ff ff       	jmp    80107404 <alltraps>

80107b31 <vector27>:
.globl vector27
vector27:
  pushl $0
80107b31:	6a 00                	push   $0x0
  pushl $27
80107b33:	6a 1b                	push   $0x1b
  jmp alltraps
80107b35:	e9 ca f8 ff ff       	jmp    80107404 <alltraps>

80107b3a <vector28>:
.globl vector28
vector28:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $28
80107b3c:	6a 1c                	push   $0x1c
  jmp alltraps
80107b3e:	e9 c1 f8 ff ff       	jmp    80107404 <alltraps>

80107b43 <vector29>:
.globl vector29
vector29:
  pushl $0
80107b43:	6a 00                	push   $0x0
  pushl $29
80107b45:	6a 1d                	push   $0x1d
  jmp alltraps
80107b47:	e9 b8 f8 ff ff       	jmp    80107404 <alltraps>

80107b4c <vector30>:
.globl vector30
vector30:
  pushl $0
80107b4c:	6a 00                	push   $0x0
  pushl $30
80107b4e:	6a 1e                	push   $0x1e
  jmp alltraps
80107b50:	e9 af f8 ff ff       	jmp    80107404 <alltraps>

80107b55 <vector31>:
.globl vector31
vector31:
  pushl $0
80107b55:	6a 00                	push   $0x0
  pushl $31
80107b57:	6a 1f                	push   $0x1f
  jmp alltraps
80107b59:	e9 a6 f8 ff ff       	jmp    80107404 <alltraps>

80107b5e <vector32>:
.globl vector32
vector32:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $32
80107b60:	6a 20                	push   $0x20
  jmp alltraps
80107b62:	e9 9d f8 ff ff       	jmp    80107404 <alltraps>

80107b67 <vector33>:
.globl vector33
vector33:
  pushl $0
80107b67:	6a 00                	push   $0x0
  pushl $33
80107b69:	6a 21                	push   $0x21
  jmp alltraps
80107b6b:	e9 94 f8 ff ff       	jmp    80107404 <alltraps>

80107b70 <vector34>:
.globl vector34
vector34:
  pushl $0
80107b70:	6a 00                	push   $0x0
  pushl $34
80107b72:	6a 22                	push   $0x22
  jmp alltraps
80107b74:	e9 8b f8 ff ff       	jmp    80107404 <alltraps>

80107b79 <vector35>:
.globl vector35
vector35:
  pushl $0
80107b79:	6a 00                	push   $0x0
  pushl $35
80107b7b:	6a 23                	push   $0x23
  jmp alltraps
80107b7d:	e9 82 f8 ff ff       	jmp    80107404 <alltraps>

80107b82 <vector36>:
.globl vector36
vector36:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $36
80107b84:	6a 24                	push   $0x24
  jmp alltraps
80107b86:	e9 79 f8 ff ff       	jmp    80107404 <alltraps>

80107b8b <vector37>:
.globl vector37
vector37:
  pushl $0
80107b8b:	6a 00                	push   $0x0
  pushl $37
80107b8d:	6a 25                	push   $0x25
  jmp alltraps
80107b8f:	e9 70 f8 ff ff       	jmp    80107404 <alltraps>

80107b94 <vector38>:
.globl vector38
vector38:
  pushl $0
80107b94:	6a 00                	push   $0x0
  pushl $38
80107b96:	6a 26                	push   $0x26
  jmp alltraps
80107b98:	e9 67 f8 ff ff       	jmp    80107404 <alltraps>

80107b9d <vector39>:
.globl vector39
vector39:
  pushl $0
80107b9d:	6a 00                	push   $0x0
  pushl $39
80107b9f:	6a 27                	push   $0x27
  jmp alltraps
80107ba1:	e9 5e f8 ff ff       	jmp    80107404 <alltraps>

80107ba6 <vector40>:
.globl vector40
vector40:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $40
80107ba8:	6a 28                	push   $0x28
  jmp alltraps
80107baa:	e9 55 f8 ff ff       	jmp    80107404 <alltraps>

80107baf <vector41>:
.globl vector41
vector41:
  pushl $0
80107baf:	6a 00                	push   $0x0
  pushl $41
80107bb1:	6a 29                	push   $0x29
  jmp alltraps
80107bb3:	e9 4c f8 ff ff       	jmp    80107404 <alltraps>

80107bb8 <vector42>:
.globl vector42
vector42:
  pushl $0
80107bb8:	6a 00                	push   $0x0
  pushl $42
80107bba:	6a 2a                	push   $0x2a
  jmp alltraps
80107bbc:	e9 43 f8 ff ff       	jmp    80107404 <alltraps>

80107bc1 <vector43>:
.globl vector43
vector43:
  pushl $0
80107bc1:	6a 00                	push   $0x0
  pushl $43
80107bc3:	6a 2b                	push   $0x2b
  jmp alltraps
80107bc5:	e9 3a f8 ff ff       	jmp    80107404 <alltraps>

80107bca <vector44>:
.globl vector44
vector44:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $44
80107bcc:	6a 2c                	push   $0x2c
  jmp alltraps
80107bce:	e9 31 f8 ff ff       	jmp    80107404 <alltraps>

80107bd3 <vector45>:
.globl vector45
vector45:
  pushl $0
80107bd3:	6a 00                	push   $0x0
  pushl $45
80107bd5:	6a 2d                	push   $0x2d
  jmp alltraps
80107bd7:	e9 28 f8 ff ff       	jmp    80107404 <alltraps>

80107bdc <vector46>:
.globl vector46
vector46:
  pushl $0
80107bdc:	6a 00                	push   $0x0
  pushl $46
80107bde:	6a 2e                	push   $0x2e
  jmp alltraps
80107be0:	e9 1f f8 ff ff       	jmp    80107404 <alltraps>

80107be5 <vector47>:
.globl vector47
vector47:
  pushl $0
80107be5:	6a 00                	push   $0x0
  pushl $47
80107be7:	6a 2f                	push   $0x2f
  jmp alltraps
80107be9:	e9 16 f8 ff ff       	jmp    80107404 <alltraps>

80107bee <vector48>:
.globl vector48
vector48:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $48
80107bf0:	6a 30                	push   $0x30
  jmp alltraps
80107bf2:	e9 0d f8 ff ff       	jmp    80107404 <alltraps>

80107bf7 <vector49>:
.globl vector49
vector49:
  pushl $0
80107bf7:	6a 00                	push   $0x0
  pushl $49
80107bf9:	6a 31                	push   $0x31
  jmp alltraps
80107bfb:	e9 04 f8 ff ff       	jmp    80107404 <alltraps>

80107c00 <vector50>:
.globl vector50
vector50:
  pushl $0
80107c00:	6a 00                	push   $0x0
  pushl $50
80107c02:	6a 32                	push   $0x32
  jmp alltraps
80107c04:	e9 fb f7 ff ff       	jmp    80107404 <alltraps>

80107c09 <vector51>:
.globl vector51
vector51:
  pushl $0
80107c09:	6a 00                	push   $0x0
  pushl $51
80107c0b:	6a 33                	push   $0x33
  jmp alltraps
80107c0d:	e9 f2 f7 ff ff       	jmp    80107404 <alltraps>

80107c12 <vector52>:
.globl vector52
vector52:
  pushl $0
80107c12:	6a 00                	push   $0x0
  pushl $52
80107c14:	6a 34                	push   $0x34
  jmp alltraps
80107c16:	e9 e9 f7 ff ff       	jmp    80107404 <alltraps>

80107c1b <vector53>:
.globl vector53
vector53:
  pushl $0
80107c1b:	6a 00                	push   $0x0
  pushl $53
80107c1d:	6a 35                	push   $0x35
  jmp alltraps
80107c1f:	e9 e0 f7 ff ff       	jmp    80107404 <alltraps>

80107c24 <vector54>:
.globl vector54
vector54:
  pushl $0
80107c24:	6a 00                	push   $0x0
  pushl $54
80107c26:	6a 36                	push   $0x36
  jmp alltraps
80107c28:	e9 d7 f7 ff ff       	jmp    80107404 <alltraps>

80107c2d <vector55>:
.globl vector55
vector55:
  pushl $0
80107c2d:	6a 00                	push   $0x0
  pushl $55
80107c2f:	6a 37                	push   $0x37
  jmp alltraps
80107c31:	e9 ce f7 ff ff       	jmp    80107404 <alltraps>

80107c36 <vector56>:
.globl vector56
vector56:
  pushl $0
80107c36:	6a 00                	push   $0x0
  pushl $56
80107c38:	6a 38                	push   $0x38
  jmp alltraps
80107c3a:	e9 c5 f7 ff ff       	jmp    80107404 <alltraps>

80107c3f <vector57>:
.globl vector57
vector57:
  pushl $0
80107c3f:	6a 00                	push   $0x0
  pushl $57
80107c41:	6a 39                	push   $0x39
  jmp alltraps
80107c43:	e9 bc f7 ff ff       	jmp    80107404 <alltraps>

80107c48 <vector58>:
.globl vector58
vector58:
  pushl $0
80107c48:	6a 00                	push   $0x0
  pushl $58
80107c4a:	6a 3a                	push   $0x3a
  jmp alltraps
80107c4c:	e9 b3 f7 ff ff       	jmp    80107404 <alltraps>

80107c51 <vector59>:
.globl vector59
vector59:
  pushl $0
80107c51:	6a 00                	push   $0x0
  pushl $59
80107c53:	6a 3b                	push   $0x3b
  jmp alltraps
80107c55:	e9 aa f7 ff ff       	jmp    80107404 <alltraps>

80107c5a <vector60>:
.globl vector60
vector60:
  pushl $0
80107c5a:	6a 00                	push   $0x0
  pushl $60
80107c5c:	6a 3c                	push   $0x3c
  jmp alltraps
80107c5e:	e9 a1 f7 ff ff       	jmp    80107404 <alltraps>

80107c63 <vector61>:
.globl vector61
vector61:
  pushl $0
80107c63:	6a 00                	push   $0x0
  pushl $61
80107c65:	6a 3d                	push   $0x3d
  jmp alltraps
80107c67:	e9 98 f7 ff ff       	jmp    80107404 <alltraps>

80107c6c <vector62>:
.globl vector62
vector62:
  pushl $0
80107c6c:	6a 00                	push   $0x0
  pushl $62
80107c6e:	6a 3e                	push   $0x3e
  jmp alltraps
80107c70:	e9 8f f7 ff ff       	jmp    80107404 <alltraps>

80107c75 <vector63>:
.globl vector63
vector63:
  pushl $0
80107c75:	6a 00                	push   $0x0
  pushl $63
80107c77:	6a 3f                	push   $0x3f
  jmp alltraps
80107c79:	e9 86 f7 ff ff       	jmp    80107404 <alltraps>

80107c7e <vector64>:
.globl vector64
vector64:
  pushl $0
80107c7e:	6a 00                	push   $0x0
  pushl $64
80107c80:	6a 40                	push   $0x40
  jmp alltraps
80107c82:	e9 7d f7 ff ff       	jmp    80107404 <alltraps>

80107c87 <vector65>:
.globl vector65
vector65:
  pushl $0
80107c87:	6a 00                	push   $0x0
  pushl $65
80107c89:	6a 41                	push   $0x41
  jmp alltraps
80107c8b:	e9 74 f7 ff ff       	jmp    80107404 <alltraps>

80107c90 <vector66>:
.globl vector66
vector66:
  pushl $0
80107c90:	6a 00                	push   $0x0
  pushl $66
80107c92:	6a 42                	push   $0x42
  jmp alltraps
80107c94:	e9 6b f7 ff ff       	jmp    80107404 <alltraps>

80107c99 <vector67>:
.globl vector67
vector67:
  pushl $0
80107c99:	6a 00                	push   $0x0
  pushl $67
80107c9b:	6a 43                	push   $0x43
  jmp alltraps
80107c9d:	e9 62 f7 ff ff       	jmp    80107404 <alltraps>

80107ca2 <vector68>:
.globl vector68
vector68:
  pushl $0
80107ca2:	6a 00                	push   $0x0
  pushl $68
80107ca4:	6a 44                	push   $0x44
  jmp alltraps
80107ca6:	e9 59 f7 ff ff       	jmp    80107404 <alltraps>

80107cab <vector69>:
.globl vector69
vector69:
  pushl $0
80107cab:	6a 00                	push   $0x0
  pushl $69
80107cad:	6a 45                	push   $0x45
  jmp alltraps
80107caf:	e9 50 f7 ff ff       	jmp    80107404 <alltraps>

80107cb4 <vector70>:
.globl vector70
vector70:
  pushl $0
80107cb4:	6a 00                	push   $0x0
  pushl $70
80107cb6:	6a 46                	push   $0x46
  jmp alltraps
80107cb8:	e9 47 f7 ff ff       	jmp    80107404 <alltraps>

80107cbd <vector71>:
.globl vector71
vector71:
  pushl $0
80107cbd:	6a 00                	push   $0x0
  pushl $71
80107cbf:	6a 47                	push   $0x47
  jmp alltraps
80107cc1:	e9 3e f7 ff ff       	jmp    80107404 <alltraps>

80107cc6 <vector72>:
.globl vector72
vector72:
  pushl $0
80107cc6:	6a 00                	push   $0x0
  pushl $72
80107cc8:	6a 48                	push   $0x48
  jmp alltraps
80107cca:	e9 35 f7 ff ff       	jmp    80107404 <alltraps>

80107ccf <vector73>:
.globl vector73
vector73:
  pushl $0
80107ccf:	6a 00                	push   $0x0
  pushl $73
80107cd1:	6a 49                	push   $0x49
  jmp alltraps
80107cd3:	e9 2c f7 ff ff       	jmp    80107404 <alltraps>

80107cd8 <vector74>:
.globl vector74
vector74:
  pushl $0
80107cd8:	6a 00                	push   $0x0
  pushl $74
80107cda:	6a 4a                	push   $0x4a
  jmp alltraps
80107cdc:	e9 23 f7 ff ff       	jmp    80107404 <alltraps>

80107ce1 <vector75>:
.globl vector75
vector75:
  pushl $0
80107ce1:	6a 00                	push   $0x0
  pushl $75
80107ce3:	6a 4b                	push   $0x4b
  jmp alltraps
80107ce5:	e9 1a f7 ff ff       	jmp    80107404 <alltraps>

80107cea <vector76>:
.globl vector76
vector76:
  pushl $0
80107cea:	6a 00                	push   $0x0
  pushl $76
80107cec:	6a 4c                	push   $0x4c
  jmp alltraps
80107cee:	e9 11 f7 ff ff       	jmp    80107404 <alltraps>

80107cf3 <vector77>:
.globl vector77
vector77:
  pushl $0
80107cf3:	6a 00                	push   $0x0
  pushl $77
80107cf5:	6a 4d                	push   $0x4d
  jmp alltraps
80107cf7:	e9 08 f7 ff ff       	jmp    80107404 <alltraps>

80107cfc <vector78>:
.globl vector78
vector78:
  pushl $0
80107cfc:	6a 00                	push   $0x0
  pushl $78
80107cfe:	6a 4e                	push   $0x4e
  jmp alltraps
80107d00:	e9 ff f6 ff ff       	jmp    80107404 <alltraps>

80107d05 <vector79>:
.globl vector79
vector79:
  pushl $0
80107d05:	6a 00                	push   $0x0
  pushl $79
80107d07:	6a 4f                	push   $0x4f
  jmp alltraps
80107d09:	e9 f6 f6 ff ff       	jmp    80107404 <alltraps>

80107d0e <vector80>:
.globl vector80
vector80:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $80
80107d10:	6a 50                	push   $0x50
  jmp alltraps
80107d12:	e9 ed f6 ff ff       	jmp    80107404 <alltraps>

80107d17 <vector81>:
.globl vector81
vector81:
  pushl $0
80107d17:	6a 00                	push   $0x0
  pushl $81
80107d19:	6a 51                	push   $0x51
  jmp alltraps
80107d1b:	e9 e4 f6 ff ff       	jmp    80107404 <alltraps>

80107d20 <vector82>:
.globl vector82
vector82:
  pushl $0
80107d20:	6a 00                	push   $0x0
  pushl $82
80107d22:	6a 52                	push   $0x52
  jmp alltraps
80107d24:	e9 db f6 ff ff       	jmp    80107404 <alltraps>

80107d29 <vector83>:
.globl vector83
vector83:
  pushl $0
80107d29:	6a 00                	push   $0x0
  pushl $83
80107d2b:	6a 53                	push   $0x53
  jmp alltraps
80107d2d:	e9 d2 f6 ff ff       	jmp    80107404 <alltraps>

80107d32 <vector84>:
.globl vector84
vector84:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $84
80107d34:	6a 54                	push   $0x54
  jmp alltraps
80107d36:	e9 c9 f6 ff ff       	jmp    80107404 <alltraps>

80107d3b <vector85>:
.globl vector85
vector85:
  pushl $0
80107d3b:	6a 00                	push   $0x0
  pushl $85
80107d3d:	6a 55                	push   $0x55
  jmp alltraps
80107d3f:	e9 c0 f6 ff ff       	jmp    80107404 <alltraps>

80107d44 <vector86>:
.globl vector86
vector86:
  pushl $0
80107d44:	6a 00                	push   $0x0
  pushl $86
80107d46:	6a 56                	push   $0x56
  jmp alltraps
80107d48:	e9 b7 f6 ff ff       	jmp    80107404 <alltraps>

80107d4d <vector87>:
.globl vector87
vector87:
  pushl $0
80107d4d:	6a 00                	push   $0x0
  pushl $87
80107d4f:	6a 57                	push   $0x57
  jmp alltraps
80107d51:	e9 ae f6 ff ff       	jmp    80107404 <alltraps>

80107d56 <vector88>:
.globl vector88
vector88:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $88
80107d58:	6a 58                	push   $0x58
  jmp alltraps
80107d5a:	e9 a5 f6 ff ff       	jmp    80107404 <alltraps>

80107d5f <vector89>:
.globl vector89
vector89:
  pushl $0
80107d5f:	6a 00                	push   $0x0
  pushl $89
80107d61:	6a 59                	push   $0x59
  jmp alltraps
80107d63:	e9 9c f6 ff ff       	jmp    80107404 <alltraps>

80107d68 <vector90>:
.globl vector90
vector90:
  pushl $0
80107d68:	6a 00                	push   $0x0
  pushl $90
80107d6a:	6a 5a                	push   $0x5a
  jmp alltraps
80107d6c:	e9 93 f6 ff ff       	jmp    80107404 <alltraps>

80107d71 <vector91>:
.globl vector91
vector91:
  pushl $0
80107d71:	6a 00                	push   $0x0
  pushl $91
80107d73:	6a 5b                	push   $0x5b
  jmp alltraps
80107d75:	e9 8a f6 ff ff       	jmp    80107404 <alltraps>

80107d7a <vector92>:
.globl vector92
vector92:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $92
80107d7c:	6a 5c                	push   $0x5c
  jmp alltraps
80107d7e:	e9 81 f6 ff ff       	jmp    80107404 <alltraps>

80107d83 <vector93>:
.globl vector93
vector93:
  pushl $0
80107d83:	6a 00                	push   $0x0
  pushl $93
80107d85:	6a 5d                	push   $0x5d
  jmp alltraps
80107d87:	e9 78 f6 ff ff       	jmp    80107404 <alltraps>

80107d8c <vector94>:
.globl vector94
vector94:
  pushl $0
80107d8c:	6a 00                	push   $0x0
  pushl $94
80107d8e:	6a 5e                	push   $0x5e
  jmp alltraps
80107d90:	e9 6f f6 ff ff       	jmp    80107404 <alltraps>

80107d95 <vector95>:
.globl vector95
vector95:
  pushl $0
80107d95:	6a 00                	push   $0x0
  pushl $95
80107d97:	6a 5f                	push   $0x5f
  jmp alltraps
80107d99:	e9 66 f6 ff ff       	jmp    80107404 <alltraps>

80107d9e <vector96>:
.globl vector96
vector96:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $96
80107da0:	6a 60                	push   $0x60
  jmp alltraps
80107da2:	e9 5d f6 ff ff       	jmp    80107404 <alltraps>

80107da7 <vector97>:
.globl vector97
vector97:
  pushl $0
80107da7:	6a 00                	push   $0x0
  pushl $97
80107da9:	6a 61                	push   $0x61
  jmp alltraps
80107dab:	e9 54 f6 ff ff       	jmp    80107404 <alltraps>

80107db0 <vector98>:
.globl vector98
vector98:
  pushl $0
80107db0:	6a 00                	push   $0x0
  pushl $98
80107db2:	6a 62                	push   $0x62
  jmp alltraps
80107db4:	e9 4b f6 ff ff       	jmp    80107404 <alltraps>

80107db9 <vector99>:
.globl vector99
vector99:
  pushl $0
80107db9:	6a 00                	push   $0x0
  pushl $99
80107dbb:	6a 63                	push   $0x63
  jmp alltraps
80107dbd:	e9 42 f6 ff ff       	jmp    80107404 <alltraps>

80107dc2 <vector100>:
.globl vector100
vector100:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $100
80107dc4:	6a 64                	push   $0x64
  jmp alltraps
80107dc6:	e9 39 f6 ff ff       	jmp    80107404 <alltraps>

80107dcb <vector101>:
.globl vector101
vector101:
  pushl $0
80107dcb:	6a 00                	push   $0x0
  pushl $101
80107dcd:	6a 65                	push   $0x65
  jmp alltraps
80107dcf:	e9 30 f6 ff ff       	jmp    80107404 <alltraps>

80107dd4 <vector102>:
.globl vector102
vector102:
  pushl $0
80107dd4:	6a 00                	push   $0x0
  pushl $102
80107dd6:	6a 66                	push   $0x66
  jmp alltraps
80107dd8:	e9 27 f6 ff ff       	jmp    80107404 <alltraps>

80107ddd <vector103>:
.globl vector103
vector103:
  pushl $0
80107ddd:	6a 00                	push   $0x0
  pushl $103
80107ddf:	6a 67                	push   $0x67
  jmp alltraps
80107de1:	e9 1e f6 ff ff       	jmp    80107404 <alltraps>

80107de6 <vector104>:
.globl vector104
vector104:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $104
80107de8:	6a 68                	push   $0x68
  jmp alltraps
80107dea:	e9 15 f6 ff ff       	jmp    80107404 <alltraps>

80107def <vector105>:
.globl vector105
vector105:
  pushl $0
80107def:	6a 00                	push   $0x0
  pushl $105
80107df1:	6a 69                	push   $0x69
  jmp alltraps
80107df3:	e9 0c f6 ff ff       	jmp    80107404 <alltraps>

80107df8 <vector106>:
.globl vector106
vector106:
  pushl $0
80107df8:	6a 00                	push   $0x0
  pushl $106
80107dfa:	6a 6a                	push   $0x6a
  jmp alltraps
80107dfc:	e9 03 f6 ff ff       	jmp    80107404 <alltraps>

80107e01 <vector107>:
.globl vector107
vector107:
  pushl $0
80107e01:	6a 00                	push   $0x0
  pushl $107
80107e03:	6a 6b                	push   $0x6b
  jmp alltraps
80107e05:	e9 fa f5 ff ff       	jmp    80107404 <alltraps>

80107e0a <vector108>:
.globl vector108
vector108:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $108
80107e0c:	6a 6c                	push   $0x6c
  jmp alltraps
80107e0e:	e9 f1 f5 ff ff       	jmp    80107404 <alltraps>

80107e13 <vector109>:
.globl vector109
vector109:
  pushl $0
80107e13:	6a 00                	push   $0x0
  pushl $109
80107e15:	6a 6d                	push   $0x6d
  jmp alltraps
80107e17:	e9 e8 f5 ff ff       	jmp    80107404 <alltraps>

80107e1c <vector110>:
.globl vector110
vector110:
  pushl $0
80107e1c:	6a 00                	push   $0x0
  pushl $110
80107e1e:	6a 6e                	push   $0x6e
  jmp alltraps
80107e20:	e9 df f5 ff ff       	jmp    80107404 <alltraps>

80107e25 <vector111>:
.globl vector111
vector111:
  pushl $0
80107e25:	6a 00                	push   $0x0
  pushl $111
80107e27:	6a 6f                	push   $0x6f
  jmp alltraps
80107e29:	e9 d6 f5 ff ff       	jmp    80107404 <alltraps>

80107e2e <vector112>:
.globl vector112
vector112:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $112
80107e30:	6a 70                	push   $0x70
  jmp alltraps
80107e32:	e9 cd f5 ff ff       	jmp    80107404 <alltraps>

80107e37 <vector113>:
.globl vector113
vector113:
  pushl $0
80107e37:	6a 00                	push   $0x0
  pushl $113
80107e39:	6a 71                	push   $0x71
  jmp alltraps
80107e3b:	e9 c4 f5 ff ff       	jmp    80107404 <alltraps>

80107e40 <vector114>:
.globl vector114
vector114:
  pushl $0
80107e40:	6a 00                	push   $0x0
  pushl $114
80107e42:	6a 72                	push   $0x72
  jmp alltraps
80107e44:	e9 bb f5 ff ff       	jmp    80107404 <alltraps>

80107e49 <vector115>:
.globl vector115
vector115:
  pushl $0
80107e49:	6a 00                	push   $0x0
  pushl $115
80107e4b:	6a 73                	push   $0x73
  jmp alltraps
80107e4d:	e9 b2 f5 ff ff       	jmp    80107404 <alltraps>

80107e52 <vector116>:
.globl vector116
vector116:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $116
80107e54:	6a 74                	push   $0x74
  jmp alltraps
80107e56:	e9 a9 f5 ff ff       	jmp    80107404 <alltraps>

80107e5b <vector117>:
.globl vector117
vector117:
  pushl $0
80107e5b:	6a 00                	push   $0x0
  pushl $117
80107e5d:	6a 75                	push   $0x75
  jmp alltraps
80107e5f:	e9 a0 f5 ff ff       	jmp    80107404 <alltraps>

80107e64 <vector118>:
.globl vector118
vector118:
  pushl $0
80107e64:	6a 00                	push   $0x0
  pushl $118
80107e66:	6a 76                	push   $0x76
  jmp alltraps
80107e68:	e9 97 f5 ff ff       	jmp    80107404 <alltraps>

80107e6d <vector119>:
.globl vector119
vector119:
  pushl $0
80107e6d:	6a 00                	push   $0x0
  pushl $119
80107e6f:	6a 77                	push   $0x77
  jmp alltraps
80107e71:	e9 8e f5 ff ff       	jmp    80107404 <alltraps>

80107e76 <vector120>:
.globl vector120
vector120:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $120
80107e78:	6a 78                	push   $0x78
  jmp alltraps
80107e7a:	e9 85 f5 ff ff       	jmp    80107404 <alltraps>

80107e7f <vector121>:
.globl vector121
vector121:
  pushl $0
80107e7f:	6a 00                	push   $0x0
  pushl $121
80107e81:	6a 79                	push   $0x79
  jmp alltraps
80107e83:	e9 7c f5 ff ff       	jmp    80107404 <alltraps>

80107e88 <vector122>:
.globl vector122
vector122:
  pushl $0
80107e88:	6a 00                	push   $0x0
  pushl $122
80107e8a:	6a 7a                	push   $0x7a
  jmp alltraps
80107e8c:	e9 73 f5 ff ff       	jmp    80107404 <alltraps>

80107e91 <vector123>:
.globl vector123
vector123:
  pushl $0
80107e91:	6a 00                	push   $0x0
  pushl $123
80107e93:	6a 7b                	push   $0x7b
  jmp alltraps
80107e95:	e9 6a f5 ff ff       	jmp    80107404 <alltraps>

80107e9a <vector124>:
.globl vector124
vector124:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $124
80107e9c:	6a 7c                	push   $0x7c
  jmp alltraps
80107e9e:	e9 61 f5 ff ff       	jmp    80107404 <alltraps>

80107ea3 <vector125>:
.globl vector125
vector125:
  pushl $0
80107ea3:	6a 00                	push   $0x0
  pushl $125
80107ea5:	6a 7d                	push   $0x7d
  jmp alltraps
80107ea7:	e9 58 f5 ff ff       	jmp    80107404 <alltraps>

80107eac <vector126>:
.globl vector126
vector126:
  pushl $0
80107eac:	6a 00                	push   $0x0
  pushl $126
80107eae:	6a 7e                	push   $0x7e
  jmp alltraps
80107eb0:	e9 4f f5 ff ff       	jmp    80107404 <alltraps>

80107eb5 <vector127>:
.globl vector127
vector127:
  pushl $0
80107eb5:	6a 00                	push   $0x0
  pushl $127
80107eb7:	6a 7f                	push   $0x7f
  jmp alltraps
80107eb9:	e9 46 f5 ff ff       	jmp    80107404 <alltraps>

80107ebe <vector128>:
.globl vector128
vector128:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $128
80107ec0:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107ec5:	e9 3a f5 ff ff       	jmp    80107404 <alltraps>

80107eca <vector129>:
.globl vector129
vector129:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $129
80107ecc:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107ed1:	e9 2e f5 ff ff       	jmp    80107404 <alltraps>

80107ed6 <vector130>:
.globl vector130
vector130:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $130
80107ed8:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107edd:	e9 22 f5 ff ff       	jmp    80107404 <alltraps>

80107ee2 <vector131>:
.globl vector131
vector131:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $131
80107ee4:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107ee9:	e9 16 f5 ff ff       	jmp    80107404 <alltraps>

80107eee <vector132>:
.globl vector132
vector132:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $132
80107ef0:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107ef5:	e9 0a f5 ff ff       	jmp    80107404 <alltraps>

80107efa <vector133>:
.globl vector133
vector133:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $133
80107efc:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107f01:	e9 fe f4 ff ff       	jmp    80107404 <alltraps>

80107f06 <vector134>:
.globl vector134
vector134:
  pushl $0
80107f06:	6a 00                	push   $0x0
  pushl $134
80107f08:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107f0d:	e9 f2 f4 ff ff       	jmp    80107404 <alltraps>

80107f12 <vector135>:
.globl vector135
vector135:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $135
80107f14:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107f19:	e9 e6 f4 ff ff       	jmp    80107404 <alltraps>

80107f1e <vector136>:
.globl vector136
vector136:
  pushl $0
80107f1e:	6a 00                	push   $0x0
  pushl $136
80107f20:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107f25:	e9 da f4 ff ff       	jmp    80107404 <alltraps>

80107f2a <vector137>:
.globl vector137
vector137:
  pushl $0
80107f2a:	6a 00                	push   $0x0
  pushl $137
80107f2c:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107f31:	e9 ce f4 ff ff       	jmp    80107404 <alltraps>

80107f36 <vector138>:
.globl vector138
vector138:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $138
80107f38:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107f3d:	e9 c2 f4 ff ff       	jmp    80107404 <alltraps>

80107f42 <vector139>:
.globl vector139
vector139:
  pushl $0
80107f42:	6a 00                	push   $0x0
  pushl $139
80107f44:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107f49:	e9 b6 f4 ff ff       	jmp    80107404 <alltraps>

80107f4e <vector140>:
.globl vector140
vector140:
  pushl $0
80107f4e:	6a 00                	push   $0x0
  pushl $140
80107f50:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107f55:	e9 aa f4 ff ff       	jmp    80107404 <alltraps>

80107f5a <vector141>:
.globl vector141
vector141:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $141
80107f5c:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107f61:	e9 9e f4 ff ff       	jmp    80107404 <alltraps>

80107f66 <vector142>:
.globl vector142
vector142:
  pushl $0
80107f66:	6a 00                	push   $0x0
  pushl $142
80107f68:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107f6d:	e9 92 f4 ff ff       	jmp    80107404 <alltraps>

80107f72 <vector143>:
.globl vector143
vector143:
  pushl $0
80107f72:	6a 00                	push   $0x0
  pushl $143
80107f74:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107f79:	e9 86 f4 ff ff       	jmp    80107404 <alltraps>

80107f7e <vector144>:
.globl vector144
vector144:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $144
80107f80:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107f85:	e9 7a f4 ff ff       	jmp    80107404 <alltraps>

80107f8a <vector145>:
.globl vector145
vector145:
  pushl $0
80107f8a:	6a 00                	push   $0x0
  pushl $145
80107f8c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107f91:	e9 6e f4 ff ff       	jmp    80107404 <alltraps>

80107f96 <vector146>:
.globl vector146
vector146:
  pushl $0
80107f96:	6a 00                	push   $0x0
  pushl $146
80107f98:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107f9d:	e9 62 f4 ff ff       	jmp    80107404 <alltraps>

80107fa2 <vector147>:
.globl vector147
vector147:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $147
80107fa4:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107fa9:	e9 56 f4 ff ff       	jmp    80107404 <alltraps>

80107fae <vector148>:
.globl vector148
vector148:
  pushl $0
80107fae:	6a 00                	push   $0x0
  pushl $148
80107fb0:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107fb5:	e9 4a f4 ff ff       	jmp    80107404 <alltraps>

80107fba <vector149>:
.globl vector149
vector149:
  pushl $0
80107fba:	6a 00                	push   $0x0
  pushl $149
80107fbc:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107fc1:	e9 3e f4 ff ff       	jmp    80107404 <alltraps>

80107fc6 <vector150>:
.globl vector150
vector150:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $150
80107fc8:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107fcd:	e9 32 f4 ff ff       	jmp    80107404 <alltraps>

80107fd2 <vector151>:
.globl vector151
vector151:
  pushl $0
80107fd2:	6a 00                	push   $0x0
  pushl $151
80107fd4:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107fd9:	e9 26 f4 ff ff       	jmp    80107404 <alltraps>

80107fde <vector152>:
.globl vector152
vector152:
  pushl $0
80107fde:	6a 00                	push   $0x0
  pushl $152
80107fe0:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107fe5:	e9 1a f4 ff ff       	jmp    80107404 <alltraps>

80107fea <vector153>:
.globl vector153
vector153:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $153
80107fec:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107ff1:	e9 0e f4 ff ff       	jmp    80107404 <alltraps>

80107ff6 <vector154>:
.globl vector154
vector154:
  pushl $0
80107ff6:	6a 00                	push   $0x0
  pushl $154
80107ff8:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107ffd:	e9 02 f4 ff ff       	jmp    80107404 <alltraps>

80108002 <vector155>:
.globl vector155
vector155:
  pushl $0
80108002:	6a 00                	push   $0x0
  pushl $155
80108004:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80108009:	e9 f6 f3 ff ff       	jmp    80107404 <alltraps>

8010800e <vector156>:
.globl vector156
vector156:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $156
80108010:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80108015:	e9 ea f3 ff ff       	jmp    80107404 <alltraps>

8010801a <vector157>:
.globl vector157
vector157:
  pushl $0
8010801a:	6a 00                	push   $0x0
  pushl $157
8010801c:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80108021:	e9 de f3 ff ff       	jmp    80107404 <alltraps>

80108026 <vector158>:
.globl vector158
vector158:
  pushl $0
80108026:	6a 00                	push   $0x0
  pushl $158
80108028:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010802d:	e9 d2 f3 ff ff       	jmp    80107404 <alltraps>

80108032 <vector159>:
.globl vector159
vector159:
  pushl $0
80108032:	6a 00                	push   $0x0
  pushl $159
80108034:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80108039:	e9 c6 f3 ff ff       	jmp    80107404 <alltraps>

8010803e <vector160>:
.globl vector160
vector160:
  pushl $0
8010803e:	6a 00                	push   $0x0
  pushl $160
80108040:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80108045:	e9 ba f3 ff ff       	jmp    80107404 <alltraps>

8010804a <vector161>:
.globl vector161
vector161:
  pushl $0
8010804a:	6a 00                	push   $0x0
  pushl $161
8010804c:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80108051:	e9 ae f3 ff ff       	jmp    80107404 <alltraps>

80108056 <vector162>:
.globl vector162
vector162:
  pushl $0
80108056:	6a 00                	push   $0x0
  pushl $162
80108058:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010805d:	e9 a2 f3 ff ff       	jmp    80107404 <alltraps>

80108062 <vector163>:
.globl vector163
vector163:
  pushl $0
80108062:	6a 00                	push   $0x0
  pushl $163
80108064:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80108069:	e9 96 f3 ff ff       	jmp    80107404 <alltraps>

8010806e <vector164>:
.globl vector164
vector164:
  pushl $0
8010806e:	6a 00                	push   $0x0
  pushl $164
80108070:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80108075:	e9 8a f3 ff ff       	jmp    80107404 <alltraps>

8010807a <vector165>:
.globl vector165
vector165:
  pushl $0
8010807a:	6a 00                	push   $0x0
  pushl $165
8010807c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80108081:	e9 7e f3 ff ff       	jmp    80107404 <alltraps>

80108086 <vector166>:
.globl vector166
vector166:
  pushl $0
80108086:	6a 00                	push   $0x0
  pushl $166
80108088:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010808d:	e9 72 f3 ff ff       	jmp    80107404 <alltraps>

80108092 <vector167>:
.globl vector167
vector167:
  pushl $0
80108092:	6a 00                	push   $0x0
  pushl $167
80108094:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80108099:	e9 66 f3 ff ff       	jmp    80107404 <alltraps>

8010809e <vector168>:
.globl vector168
vector168:
  pushl $0
8010809e:	6a 00                	push   $0x0
  pushl $168
801080a0:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801080a5:	e9 5a f3 ff ff       	jmp    80107404 <alltraps>

801080aa <vector169>:
.globl vector169
vector169:
  pushl $0
801080aa:	6a 00                	push   $0x0
  pushl $169
801080ac:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801080b1:	e9 4e f3 ff ff       	jmp    80107404 <alltraps>

801080b6 <vector170>:
.globl vector170
vector170:
  pushl $0
801080b6:	6a 00                	push   $0x0
  pushl $170
801080b8:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801080bd:	e9 42 f3 ff ff       	jmp    80107404 <alltraps>

801080c2 <vector171>:
.globl vector171
vector171:
  pushl $0
801080c2:	6a 00                	push   $0x0
  pushl $171
801080c4:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801080c9:	e9 36 f3 ff ff       	jmp    80107404 <alltraps>

801080ce <vector172>:
.globl vector172
vector172:
  pushl $0
801080ce:	6a 00                	push   $0x0
  pushl $172
801080d0:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801080d5:	e9 2a f3 ff ff       	jmp    80107404 <alltraps>

801080da <vector173>:
.globl vector173
vector173:
  pushl $0
801080da:	6a 00                	push   $0x0
  pushl $173
801080dc:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801080e1:	e9 1e f3 ff ff       	jmp    80107404 <alltraps>

801080e6 <vector174>:
.globl vector174
vector174:
  pushl $0
801080e6:	6a 00                	push   $0x0
  pushl $174
801080e8:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801080ed:	e9 12 f3 ff ff       	jmp    80107404 <alltraps>

801080f2 <vector175>:
.globl vector175
vector175:
  pushl $0
801080f2:	6a 00                	push   $0x0
  pushl $175
801080f4:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801080f9:	e9 06 f3 ff ff       	jmp    80107404 <alltraps>

801080fe <vector176>:
.globl vector176
vector176:
  pushl $0
801080fe:	6a 00                	push   $0x0
  pushl $176
80108100:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80108105:	e9 fa f2 ff ff       	jmp    80107404 <alltraps>

8010810a <vector177>:
.globl vector177
vector177:
  pushl $0
8010810a:	6a 00                	push   $0x0
  pushl $177
8010810c:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108111:	e9 ee f2 ff ff       	jmp    80107404 <alltraps>

80108116 <vector178>:
.globl vector178
vector178:
  pushl $0
80108116:	6a 00                	push   $0x0
  pushl $178
80108118:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010811d:	e9 e2 f2 ff ff       	jmp    80107404 <alltraps>

80108122 <vector179>:
.globl vector179
vector179:
  pushl $0
80108122:	6a 00                	push   $0x0
  pushl $179
80108124:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108129:	e9 d6 f2 ff ff       	jmp    80107404 <alltraps>

8010812e <vector180>:
.globl vector180
vector180:
  pushl $0
8010812e:	6a 00                	push   $0x0
  pushl $180
80108130:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108135:	e9 ca f2 ff ff       	jmp    80107404 <alltraps>

8010813a <vector181>:
.globl vector181
vector181:
  pushl $0
8010813a:	6a 00                	push   $0x0
  pushl $181
8010813c:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108141:	e9 be f2 ff ff       	jmp    80107404 <alltraps>

80108146 <vector182>:
.globl vector182
vector182:
  pushl $0
80108146:	6a 00                	push   $0x0
  pushl $182
80108148:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010814d:	e9 b2 f2 ff ff       	jmp    80107404 <alltraps>

80108152 <vector183>:
.globl vector183
vector183:
  pushl $0
80108152:	6a 00                	push   $0x0
  pushl $183
80108154:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108159:	e9 a6 f2 ff ff       	jmp    80107404 <alltraps>

8010815e <vector184>:
.globl vector184
vector184:
  pushl $0
8010815e:	6a 00                	push   $0x0
  pushl $184
80108160:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108165:	e9 9a f2 ff ff       	jmp    80107404 <alltraps>

8010816a <vector185>:
.globl vector185
vector185:
  pushl $0
8010816a:	6a 00                	push   $0x0
  pushl $185
8010816c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108171:	e9 8e f2 ff ff       	jmp    80107404 <alltraps>

80108176 <vector186>:
.globl vector186
vector186:
  pushl $0
80108176:	6a 00                	push   $0x0
  pushl $186
80108178:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010817d:	e9 82 f2 ff ff       	jmp    80107404 <alltraps>

80108182 <vector187>:
.globl vector187
vector187:
  pushl $0
80108182:	6a 00                	push   $0x0
  pushl $187
80108184:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108189:	e9 76 f2 ff ff       	jmp    80107404 <alltraps>

8010818e <vector188>:
.globl vector188
vector188:
  pushl $0
8010818e:	6a 00                	push   $0x0
  pushl $188
80108190:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108195:	e9 6a f2 ff ff       	jmp    80107404 <alltraps>

8010819a <vector189>:
.globl vector189
vector189:
  pushl $0
8010819a:	6a 00                	push   $0x0
  pushl $189
8010819c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801081a1:	e9 5e f2 ff ff       	jmp    80107404 <alltraps>

801081a6 <vector190>:
.globl vector190
vector190:
  pushl $0
801081a6:	6a 00                	push   $0x0
  pushl $190
801081a8:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801081ad:	e9 52 f2 ff ff       	jmp    80107404 <alltraps>

801081b2 <vector191>:
.globl vector191
vector191:
  pushl $0
801081b2:	6a 00                	push   $0x0
  pushl $191
801081b4:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801081b9:	e9 46 f2 ff ff       	jmp    80107404 <alltraps>

801081be <vector192>:
.globl vector192
vector192:
  pushl $0
801081be:	6a 00                	push   $0x0
  pushl $192
801081c0:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801081c5:	e9 3a f2 ff ff       	jmp    80107404 <alltraps>

801081ca <vector193>:
.globl vector193
vector193:
  pushl $0
801081ca:	6a 00                	push   $0x0
  pushl $193
801081cc:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801081d1:	e9 2e f2 ff ff       	jmp    80107404 <alltraps>

801081d6 <vector194>:
.globl vector194
vector194:
  pushl $0
801081d6:	6a 00                	push   $0x0
  pushl $194
801081d8:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801081dd:	e9 22 f2 ff ff       	jmp    80107404 <alltraps>

801081e2 <vector195>:
.globl vector195
vector195:
  pushl $0
801081e2:	6a 00                	push   $0x0
  pushl $195
801081e4:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801081e9:	e9 16 f2 ff ff       	jmp    80107404 <alltraps>

801081ee <vector196>:
.globl vector196
vector196:
  pushl $0
801081ee:	6a 00                	push   $0x0
  pushl $196
801081f0:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801081f5:	e9 0a f2 ff ff       	jmp    80107404 <alltraps>

801081fa <vector197>:
.globl vector197
vector197:
  pushl $0
801081fa:	6a 00                	push   $0x0
  pushl $197
801081fc:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108201:	e9 fe f1 ff ff       	jmp    80107404 <alltraps>

80108206 <vector198>:
.globl vector198
vector198:
  pushl $0
80108206:	6a 00                	push   $0x0
  pushl $198
80108208:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010820d:	e9 f2 f1 ff ff       	jmp    80107404 <alltraps>

80108212 <vector199>:
.globl vector199
vector199:
  pushl $0
80108212:	6a 00                	push   $0x0
  pushl $199
80108214:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108219:	e9 e6 f1 ff ff       	jmp    80107404 <alltraps>

8010821e <vector200>:
.globl vector200
vector200:
  pushl $0
8010821e:	6a 00                	push   $0x0
  pushl $200
80108220:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108225:	e9 da f1 ff ff       	jmp    80107404 <alltraps>

8010822a <vector201>:
.globl vector201
vector201:
  pushl $0
8010822a:	6a 00                	push   $0x0
  pushl $201
8010822c:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108231:	e9 ce f1 ff ff       	jmp    80107404 <alltraps>

80108236 <vector202>:
.globl vector202
vector202:
  pushl $0
80108236:	6a 00                	push   $0x0
  pushl $202
80108238:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010823d:	e9 c2 f1 ff ff       	jmp    80107404 <alltraps>

80108242 <vector203>:
.globl vector203
vector203:
  pushl $0
80108242:	6a 00                	push   $0x0
  pushl $203
80108244:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108249:	e9 b6 f1 ff ff       	jmp    80107404 <alltraps>

8010824e <vector204>:
.globl vector204
vector204:
  pushl $0
8010824e:	6a 00                	push   $0x0
  pushl $204
80108250:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108255:	e9 aa f1 ff ff       	jmp    80107404 <alltraps>

8010825a <vector205>:
.globl vector205
vector205:
  pushl $0
8010825a:	6a 00                	push   $0x0
  pushl $205
8010825c:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108261:	e9 9e f1 ff ff       	jmp    80107404 <alltraps>

80108266 <vector206>:
.globl vector206
vector206:
  pushl $0
80108266:	6a 00                	push   $0x0
  pushl $206
80108268:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010826d:	e9 92 f1 ff ff       	jmp    80107404 <alltraps>

80108272 <vector207>:
.globl vector207
vector207:
  pushl $0
80108272:	6a 00                	push   $0x0
  pushl $207
80108274:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108279:	e9 86 f1 ff ff       	jmp    80107404 <alltraps>

8010827e <vector208>:
.globl vector208
vector208:
  pushl $0
8010827e:	6a 00                	push   $0x0
  pushl $208
80108280:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108285:	e9 7a f1 ff ff       	jmp    80107404 <alltraps>

8010828a <vector209>:
.globl vector209
vector209:
  pushl $0
8010828a:	6a 00                	push   $0x0
  pushl $209
8010828c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80108291:	e9 6e f1 ff ff       	jmp    80107404 <alltraps>

80108296 <vector210>:
.globl vector210
vector210:
  pushl $0
80108296:	6a 00                	push   $0x0
  pushl $210
80108298:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010829d:	e9 62 f1 ff ff       	jmp    80107404 <alltraps>

801082a2 <vector211>:
.globl vector211
vector211:
  pushl $0
801082a2:	6a 00                	push   $0x0
  pushl $211
801082a4:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801082a9:	e9 56 f1 ff ff       	jmp    80107404 <alltraps>

801082ae <vector212>:
.globl vector212
vector212:
  pushl $0
801082ae:	6a 00                	push   $0x0
  pushl $212
801082b0:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801082b5:	e9 4a f1 ff ff       	jmp    80107404 <alltraps>

801082ba <vector213>:
.globl vector213
vector213:
  pushl $0
801082ba:	6a 00                	push   $0x0
  pushl $213
801082bc:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801082c1:	e9 3e f1 ff ff       	jmp    80107404 <alltraps>

801082c6 <vector214>:
.globl vector214
vector214:
  pushl $0
801082c6:	6a 00                	push   $0x0
  pushl $214
801082c8:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801082cd:	e9 32 f1 ff ff       	jmp    80107404 <alltraps>

801082d2 <vector215>:
.globl vector215
vector215:
  pushl $0
801082d2:	6a 00                	push   $0x0
  pushl $215
801082d4:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801082d9:	e9 26 f1 ff ff       	jmp    80107404 <alltraps>

801082de <vector216>:
.globl vector216
vector216:
  pushl $0
801082de:	6a 00                	push   $0x0
  pushl $216
801082e0:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801082e5:	e9 1a f1 ff ff       	jmp    80107404 <alltraps>

801082ea <vector217>:
.globl vector217
vector217:
  pushl $0
801082ea:	6a 00                	push   $0x0
  pushl $217
801082ec:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801082f1:	e9 0e f1 ff ff       	jmp    80107404 <alltraps>

801082f6 <vector218>:
.globl vector218
vector218:
  pushl $0
801082f6:	6a 00                	push   $0x0
  pushl $218
801082f8:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801082fd:	e9 02 f1 ff ff       	jmp    80107404 <alltraps>

80108302 <vector219>:
.globl vector219
vector219:
  pushl $0
80108302:	6a 00                	push   $0x0
  pushl $219
80108304:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108309:	e9 f6 f0 ff ff       	jmp    80107404 <alltraps>

8010830e <vector220>:
.globl vector220
vector220:
  pushl $0
8010830e:	6a 00                	push   $0x0
  pushl $220
80108310:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108315:	e9 ea f0 ff ff       	jmp    80107404 <alltraps>

8010831a <vector221>:
.globl vector221
vector221:
  pushl $0
8010831a:	6a 00                	push   $0x0
  pushl $221
8010831c:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108321:	e9 de f0 ff ff       	jmp    80107404 <alltraps>

80108326 <vector222>:
.globl vector222
vector222:
  pushl $0
80108326:	6a 00                	push   $0x0
  pushl $222
80108328:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010832d:	e9 d2 f0 ff ff       	jmp    80107404 <alltraps>

80108332 <vector223>:
.globl vector223
vector223:
  pushl $0
80108332:	6a 00                	push   $0x0
  pushl $223
80108334:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108339:	e9 c6 f0 ff ff       	jmp    80107404 <alltraps>

8010833e <vector224>:
.globl vector224
vector224:
  pushl $0
8010833e:	6a 00                	push   $0x0
  pushl $224
80108340:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108345:	e9 ba f0 ff ff       	jmp    80107404 <alltraps>

8010834a <vector225>:
.globl vector225
vector225:
  pushl $0
8010834a:	6a 00                	push   $0x0
  pushl $225
8010834c:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108351:	e9 ae f0 ff ff       	jmp    80107404 <alltraps>

80108356 <vector226>:
.globl vector226
vector226:
  pushl $0
80108356:	6a 00                	push   $0x0
  pushl $226
80108358:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
8010835d:	e9 a2 f0 ff ff       	jmp    80107404 <alltraps>

80108362 <vector227>:
.globl vector227
vector227:
  pushl $0
80108362:	6a 00                	push   $0x0
  pushl $227
80108364:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108369:	e9 96 f0 ff ff       	jmp    80107404 <alltraps>

8010836e <vector228>:
.globl vector228
vector228:
  pushl $0
8010836e:	6a 00                	push   $0x0
  pushl $228
80108370:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108375:	e9 8a f0 ff ff       	jmp    80107404 <alltraps>

8010837a <vector229>:
.globl vector229
vector229:
  pushl $0
8010837a:	6a 00                	push   $0x0
  pushl $229
8010837c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80108381:	e9 7e f0 ff ff       	jmp    80107404 <alltraps>

80108386 <vector230>:
.globl vector230
vector230:
  pushl $0
80108386:	6a 00                	push   $0x0
  pushl $230
80108388:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010838d:	e9 72 f0 ff ff       	jmp    80107404 <alltraps>

80108392 <vector231>:
.globl vector231
vector231:
  pushl $0
80108392:	6a 00                	push   $0x0
  pushl $231
80108394:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108399:	e9 66 f0 ff ff       	jmp    80107404 <alltraps>

8010839e <vector232>:
.globl vector232
vector232:
  pushl $0
8010839e:	6a 00                	push   $0x0
  pushl $232
801083a0:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801083a5:	e9 5a f0 ff ff       	jmp    80107404 <alltraps>

801083aa <vector233>:
.globl vector233
vector233:
  pushl $0
801083aa:	6a 00                	push   $0x0
  pushl $233
801083ac:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801083b1:	e9 4e f0 ff ff       	jmp    80107404 <alltraps>

801083b6 <vector234>:
.globl vector234
vector234:
  pushl $0
801083b6:	6a 00                	push   $0x0
  pushl $234
801083b8:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801083bd:	e9 42 f0 ff ff       	jmp    80107404 <alltraps>

801083c2 <vector235>:
.globl vector235
vector235:
  pushl $0
801083c2:	6a 00                	push   $0x0
  pushl $235
801083c4:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801083c9:	e9 36 f0 ff ff       	jmp    80107404 <alltraps>

801083ce <vector236>:
.globl vector236
vector236:
  pushl $0
801083ce:	6a 00                	push   $0x0
  pushl $236
801083d0:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801083d5:	e9 2a f0 ff ff       	jmp    80107404 <alltraps>

801083da <vector237>:
.globl vector237
vector237:
  pushl $0
801083da:	6a 00                	push   $0x0
  pushl $237
801083dc:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801083e1:	e9 1e f0 ff ff       	jmp    80107404 <alltraps>

801083e6 <vector238>:
.globl vector238
vector238:
  pushl $0
801083e6:	6a 00                	push   $0x0
  pushl $238
801083e8:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801083ed:	e9 12 f0 ff ff       	jmp    80107404 <alltraps>

801083f2 <vector239>:
.globl vector239
vector239:
  pushl $0
801083f2:	6a 00                	push   $0x0
  pushl $239
801083f4:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801083f9:	e9 06 f0 ff ff       	jmp    80107404 <alltraps>

801083fe <vector240>:
.globl vector240
vector240:
  pushl $0
801083fe:	6a 00                	push   $0x0
  pushl $240
80108400:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80108405:	e9 fa ef ff ff       	jmp    80107404 <alltraps>

8010840a <vector241>:
.globl vector241
vector241:
  pushl $0
8010840a:	6a 00                	push   $0x0
  pushl $241
8010840c:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108411:	e9 ee ef ff ff       	jmp    80107404 <alltraps>

80108416 <vector242>:
.globl vector242
vector242:
  pushl $0
80108416:	6a 00                	push   $0x0
  pushl $242
80108418:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010841d:	e9 e2 ef ff ff       	jmp    80107404 <alltraps>

80108422 <vector243>:
.globl vector243
vector243:
  pushl $0
80108422:	6a 00                	push   $0x0
  pushl $243
80108424:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108429:	e9 d6 ef ff ff       	jmp    80107404 <alltraps>

8010842e <vector244>:
.globl vector244
vector244:
  pushl $0
8010842e:	6a 00                	push   $0x0
  pushl $244
80108430:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108435:	e9 ca ef ff ff       	jmp    80107404 <alltraps>

8010843a <vector245>:
.globl vector245
vector245:
  pushl $0
8010843a:	6a 00                	push   $0x0
  pushl $245
8010843c:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108441:	e9 be ef ff ff       	jmp    80107404 <alltraps>

80108446 <vector246>:
.globl vector246
vector246:
  pushl $0
80108446:	6a 00                	push   $0x0
  pushl $246
80108448:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010844d:	e9 b2 ef ff ff       	jmp    80107404 <alltraps>

80108452 <vector247>:
.globl vector247
vector247:
  pushl $0
80108452:	6a 00                	push   $0x0
  pushl $247
80108454:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108459:	e9 a6 ef ff ff       	jmp    80107404 <alltraps>

8010845e <vector248>:
.globl vector248
vector248:
  pushl $0
8010845e:	6a 00                	push   $0x0
  pushl $248
80108460:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108465:	e9 9a ef ff ff       	jmp    80107404 <alltraps>

8010846a <vector249>:
.globl vector249
vector249:
  pushl $0
8010846a:	6a 00                	push   $0x0
  pushl $249
8010846c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108471:	e9 8e ef ff ff       	jmp    80107404 <alltraps>

80108476 <vector250>:
.globl vector250
vector250:
  pushl $0
80108476:	6a 00                	push   $0x0
  pushl $250
80108478:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
8010847d:	e9 82 ef ff ff       	jmp    80107404 <alltraps>

80108482 <vector251>:
.globl vector251
vector251:
  pushl $0
80108482:	6a 00                	push   $0x0
  pushl $251
80108484:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108489:	e9 76 ef ff ff       	jmp    80107404 <alltraps>

8010848e <vector252>:
.globl vector252
vector252:
  pushl $0
8010848e:	6a 00                	push   $0x0
  pushl $252
80108490:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108495:	e9 6a ef ff ff       	jmp    80107404 <alltraps>

8010849a <vector253>:
.globl vector253
vector253:
  pushl $0
8010849a:	6a 00                	push   $0x0
  pushl $253
8010849c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801084a1:	e9 5e ef ff ff       	jmp    80107404 <alltraps>

801084a6 <vector254>:
.globl vector254
vector254:
  pushl $0
801084a6:	6a 00                	push   $0x0
  pushl $254
801084a8:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801084ad:	e9 52 ef ff ff       	jmp    80107404 <alltraps>

801084b2 <vector255>:
.globl vector255
vector255:
  pushl $0
801084b2:	6a 00                	push   $0x0
  pushl $255
801084b4:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801084b9:	e9 46 ef ff ff       	jmp    80107404 <alltraps>
	...

801084c0 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801084c0:	55                   	push   %ebp
801084c1:	89 e5                	mov    %esp,%ebp
801084c3:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801084c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801084c9:	48                   	dec    %eax
801084ca:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801084ce:	8b 45 08             	mov    0x8(%ebp),%eax
801084d1:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801084d5:	8b 45 08             	mov    0x8(%ebp),%eax
801084d8:	c1 e8 10             	shr    $0x10,%eax
801084db:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801084df:	8d 45 fa             	lea    -0x6(%ebp),%eax
801084e2:	0f 01 10             	lgdtl  (%eax)
}
801084e5:	c9                   	leave  
801084e6:	c3                   	ret    

801084e7 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801084e7:	55                   	push   %ebp
801084e8:	89 e5                	mov    %esp,%ebp
801084ea:	83 ec 04             	sub    $0x4,%esp
801084ed:	8b 45 08             	mov    0x8(%ebp),%eax
801084f0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801084f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801084f7:	0f 00 d8             	ltr    %ax
}
801084fa:	c9                   	leave  
801084fb:	c3                   	ret    

801084fc <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
801084fc:	55                   	push   %ebp
801084fd:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801084ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108502:	0f 22 d8             	mov    %eax,%cr3
}
80108505:	5d                   	pop    %ebp
80108506:	c3                   	ret    

80108507 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108507:	55                   	push   %ebp
80108508:	89 e5                	mov    %esp,%ebp
8010850a:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
8010850d:	e8 f0 bf ff ff       	call   80104502 <cpuid>
80108512:	89 c2                	mov    %eax,%edx
80108514:	89 d0                	mov    %edx,%eax
80108516:	c1 e0 02             	shl    $0x2,%eax
80108519:	01 d0                	add    %edx,%eax
8010851b:	01 c0                	add    %eax,%eax
8010851d:	01 d0                	add    %edx,%eax
8010851f:	c1 e0 04             	shl    $0x4,%eax
80108522:	05 e0 5c 11 80       	add    $0x80115ce0,%eax
80108527:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010852a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852d:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80108533:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108536:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
8010853c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853f:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80108543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108546:	8a 50 7d             	mov    0x7d(%eax),%dl
80108549:	83 e2 f0             	and    $0xfffffff0,%edx
8010854c:	83 ca 0a             	or     $0xa,%edx
8010854f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108555:	8a 50 7d             	mov    0x7d(%eax),%dl
80108558:	83 ca 10             	or     $0x10,%edx
8010855b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010855e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108561:	8a 50 7d             	mov    0x7d(%eax),%dl
80108564:	83 e2 9f             	and    $0xffffff9f,%edx
80108567:	88 50 7d             	mov    %dl,0x7d(%eax)
8010856a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856d:	8a 50 7d             	mov    0x7d(%eax),%dl
80108570:	83 ca 80             	or     $0xffffff80,%edx
80108573:	88 50 7d             	mov    %dl,0x7d(%eax)
80108576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108579:	8a 50 7e             	mov    0x7e(%eax),%dl
8010857c:	83 ca 0f             	or     $0xf,%edx
8010857f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108585:	8a 50 7e             	mov    0x7e(%eax),%dl
80108588:	83 e2 ef             	and    $0xffffffef,%edx
8010858b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010858e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108591:	8a 50 7e             	mov    0x7e(%eax),%dl
80108594:	83 e2 df             	and    $0xffffffdf,%edx
80108597:	88 50 7e             	mov    %dl,0x7e(%eax)
8010859a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859d:	8a 50 7e             	mov    0x7e(%eax),%dl
801085a0:	83 ca 40             	or     $0x40,%edx
801085a3:	88 50 7e             	mov    %dl,0x7e(%eax)
801085a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085a9:	8a 50 7e             	mov    0x7e(%eax),%dl
801085ac:	83 ca 80             	or     $0xffffff80,%edx
801085af:	88 50 7e             	mov    %dl,0x7e(%eax)
801085b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b5:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801085b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085bc:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801085c3:	ff ff 
801085c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c8:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801085cf:	00 00 
801085d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d4:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801085db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085de:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801085e4:	83 e2 f0             	and    $0xfffffff0,%edx
801085e7:	83 ca 02             	or     $0x2,%edx
801085ea:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801085f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f3:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801085f9:	83 ca 10             	or     $0x10,%edx
801085fc:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108605:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010860b:	83 e2 9f             	and    $0xffffff9f,%edx
8010860e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108614:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108617:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010861d:	83 ca 80             	or     $0xffffff80,%edx
80108620:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108629:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010862f:	83 ca 0f             	or     $0xf,%edx
80108632:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010863b:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108641:	83 e2 ef             	and    $0xffffffef,%edx
80108644:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010864a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108653:	83 e2 df             	and    $0xffffffdf,%edx
80108656:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010865c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010865f:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108665:	83 ca 40             	or     $0x40,%edx
80108668:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010866e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108671:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108677:	83 ca 80             	or     $0xffffff80,%edx
8010867a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108680:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108683:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010868a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868d:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80108694:	ff ff 
80108696:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108699:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801086a0:	00 00 
801086a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a5:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801086ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086af:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801086b5:	83 e2 f0             	and    $0xfffffff0,%edx
801086b8:	83 ca 0a             	or     $0xa,%edx
801086bb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801086c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c4:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801086ca:	83 ca 10             	or     $0x10,%edx
801086cd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801086d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d6:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801086dc:	83 ca 60             	or     $0x60,%edx
801086df:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801086e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e8:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801086ee:	83 ca 80             	or     $0xffffff80,%edx
801086f1:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801086f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fa:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108700:	83 ca 0f             	or     $0xf,%edx
80108703:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010870c:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108712:	83 e2 ef             	and    $0xffffffef,%edx
80108715:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010871b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108724:	83 e2 df             	and    $0xffffffdf,%edx
80108727:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010872d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108730:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108736:	83 ca 40             	or     $0x40,%edx
80108739:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010873f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108742:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108748:	83 ca 80             	or     $0xffffff80,%edx
8010874b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108751:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108754:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010875b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010875e:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108765:	ff ff 
80108767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010876a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108771:	00 00 
80108773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108776:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
8010877d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108780:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108786:	83 e2 f0             	and    $0xfffffff0,%edx
80108789:	83 ca 02             	or     $0x2,%edx
8010878c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108792:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108795:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010879b:	83 ca 10             	or     $0x10,%edx
8010879e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a7:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801087ad:	83 ca 60             	or     $0x60,%edx
801087b0:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087b9:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801087bf:	83 ca 80             	or     $0xffffff80,%edx
801087c2:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801087c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087cb:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801087d1:	83 ca 0f             	or     $0xf,%edx
801087d4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087dd:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801087e3:	83 e2 ef             	and    $0xffffffef,%edx
801087e6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087ef:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801087f5:	83 e2 df             	and    $0xffffffdf,%edx
801087f8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801087fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108801:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108807:	83 ca 40             	or     $0x40,%edx
8010880a:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108810:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108813:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108819:	83 ca 80             	or     $0xffffff80,%edx
8010881c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108825:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010882c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882f:	83 c0 70             	add    $0x70,%eax
80108832:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80108839:	00 
8010883a:	89 04 24             	mov    %eax,(%esp)
8010883d:	e8 7e fc ff ff       	call   801084c0 <lgdt>
}
80108842:	c9                   	leave  
80108843:	c3                   	ret    

80108844 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108844:	55                   	push   %ebp
80108845:	89 e5                	mov    %esp,%ebp
80108847:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
8010884a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010884d:	c1 e8 16             	shr    $0x16,%eax
80108850:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108857:	8b 45 08             	mov    0x8(%ebp),%eax
8010885a:	01 d0                	add    %edx,%eax
8010885c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010885f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108862:	8b 00                	mov    (%eax),%eax
80108864:	83 e0 01             	and    $0x1,%eax
80108867:	85 c0                	test   %eax,%eax
80108869:	74 14                	je     8010887f <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010886b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010886e:	8b 00                	mov    (%eax),%eax
80108870:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108875:	05 00 00 00 80       	add    $0x80000000,%eax
8010887a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010887d:	eb 48                	jmp    801088c7 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010887f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80108883:	74 0e                	je     80108893 <walkpgdir+0x4f>
80108885:	e8 ac a6 ff ff       	call   80102f36 <kalloc>
8010888a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010888d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108891:	75 07                	jne    8010889a <walkpgdir+0x56>
      return 0;
80108893:	b8 00 00 00 00       	mov    $0x0,%eax
80108898:	eb 44                	jmp    801088de <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
8010889a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801088a1:	00 
801088a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801088a9:	00 
801088aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ad:	89 04 24             	mov    %eax,(%esp)
801088b0:	e8 21 d0 ff ff       	call   801058d6 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801088b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b8:	05 00 00 00 80       	add    $0x80000000,%eax
801088bd:	83 c8 07             	or     $0x7,%eax
801088c0:	89 c2                	mov    %eax,%edx
801088c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088c5:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801088c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801088ca:	c1 e8 0c             	shr    $0xc,%eax
801088cd:	25 ff 03 00 00       	and    $0x3ff,%eax
801088d2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801088d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088dc:	01 d0                	add    %edx,%eax
}
801088de:	c9                   	leave  
801088df:	c3                   	ret    

801088e0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801088e0:	55                   	push   %ebp
801088e1:	89 e5                	mov    %esp,%ebp
801088e3:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801088e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801088e9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801088f1:	8b 55 0c             	mov    0xc(%ebp),%edx
801088f4:	8b 45 10             	mov    0x10(%ebp),%eax
801088f7:	01 d0                	add    %edx,%eax
801088f9:	48                   	dec    %eax
801088fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80108902:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108909:	00 
8010890a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010890d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108911:	8b 45 08             	mov    0x8(%ebp),%eax
80108914:	89 04 24             	mov    %eax,(%esp)
80108917:	e8 28 ff ff ff       	call   80108844 <walkpgdir>
8010891c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010891f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108923:	75 07                	jne    8010892c <mappages+0x4c>
      return -1;
80108925:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010892a:	eb 48                	jmp    80108974 <mappages+0x94>
    if(*pte & PTE_P)
8010892c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010892f:	8b 00                	mov    (%eax),%eax
80108931:	83 e0 01             	and    $0x1,%eax
80108934:	85 c0                	test   %eax,%eax
80108936:	74 0c                	je     80108944 <mappages+0x64>
      panic("remap");
80108938:	c7 04 24 b0 a2 10 80 	movl   $0x8010a2b0,(%esp)
8010893f:	e8 10 7c ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108944:	8b 45 18             	mov    0x18(%ebp),%eax
80108947:	0b 45 14             	or     0x14(%ebp),%eax
8010894a:	83 c8 01             	or     $0x1,%eax
8010894d:	89 c2                	mov    %eax,%edx
8010894f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108952:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108954:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108957:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010895a:	75 08                	jne    80108964 <mappages+0x84>
      break;
8010895c:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
8010895d:	b8 00 00 00 00       	mov    $0x0,%eax
80108962:	eb 10                	jmp    80108974 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108964:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
8010896b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80108972:	eb 8e                	jmp    80108902 <mappages+0x22>
  return 0;
}
80108974:	c9                   	leave  
80108975:	c3                   	ret    

80108976 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108976:	55                   	push   %ebp
80108977:	89 e5                	mov    %esp,%ebp
80108979:	53                   	push   %ebx
8010897a:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010897d:	e8 b4 a5 ff ff       	call   80102f36 <kalloc>
80108982:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108985:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108989:	75 0a                	jne    80108995 <setupkvm+0x1f>
    return 0;
8010898b:	b8 00 00 00 00       	mov    $0x0,%eax
80108990:	e9 84 00 00 00       	jmp    80108a19 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80108995:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010899c:	00 
8010899d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801089a4:	00 
801089a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089a8:	89 04 24             	mov    %eax,(%esp)
801089ab:	e8 26 cf ff ff       	call   801058d6 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801089b0:	c7 45 f4 20 d5 10 80 	movl   $0x8010d520,-0xc(%ebp)
801089b7:	eb 54                	jmp    80108a0d <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801089b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bc:	8b 48 0c             	mov    0xc(%eax),%ecx
801089bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c2:	8b 50 04             	mov    0x4(%eax),%edx
801089c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c8:	8b 58 08             	mov    0x8(%eax),%ebx
801089cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089ce:	8b 40 04             	mov    0x4(%eax),%eax
801089d1:	29 c3                	sub    %eax,%ebx
801089d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089d6:	8b 00                	mov    (%eax),%eax
801089d8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801089dc:	89 54 24 0c          	mov    %edx,0xc(%esp)
801089e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801089e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801089e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089eb:	89 04 24             	mov    %eax,(%esp)
801089ee:	e8 ed fe ff ff       	call   801088e0 <mappages>
801089f3:	85 c0                	test   %eax,%eax
801089f5:	79 12                	jns    80108a09 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
801089f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089fa:	89 04 24             	mov    %eax,(%esp)
801089fd:	e8 1a 05 00 00       	call   80108f1c <freevm>
      return 0;
80108a02:	b8 00 00 00 00       	mov    $0x0,%eax
80108a07:	eb 10                	jmp    80108a19 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108a09:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108a0d:	81 7d f4 60 d5 10 80 	cmpl   $0x8010d560,-0xc(%ebp)
80108a14:	72 a3                	jb     801089b9 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80108a16:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108a19:	83 c4 34             	add    $0x34,%esp
80108a1c:	5b                   	pop    %ebx
80108a1d:	5d                   	pop    %ebp
80108a1e:	c3                   	ret    

80108a1f <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108a1f:	55                   	push   %ebp
80108a20:	89 e5                	mov    %esp,%ebp
80108a22:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108a25:	e8 4c ff ff ff       	call   80108976 <setupkvm>
80108a2a:	a3 04 8d 11 80       	mov    %eax,0x80118d04
  switchkvm();
80108a2f:	e8 02 00 00 00       	call   80108a36 <switchkvm>
}
80108a34:	c9                   	leave  
80108a35:	c3                   	ret    

80108a36 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108a36:	55                   	push   %ebp
80108a37:	89 e5                	mov    %esp,%ebp
80108a39:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108a3c:	a1 04 8d 11 80       	mov    0x80118d04,%eax
80108a41:	05 00 00 00 80       	add    $0x80000000,%eax
80108a46:	89 04 24             	mov    %eax,(%esp)
80108a49:	e8 ae fa ff ff       	call   801084fc <lcr3>
}
80108a4e:	c9                   	leave  
80108a4f:	c3                   	ret    

80108a50 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108a50:	55                   	push   %ebp
80108a51:	89 e5                	mov    %esp,%ebp
80108a53:	57                   	push   %edi
80108a54:	56                   	push   %esi
80108a55:	53                   	push   %ebx
80108a56:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80108a59:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108a5d:	75 0c                	jne    80108a6b <switchuvm+0x1b>
    panic("switchuvm: no process");
80108a5f:	c7 04 24 b6 a2 10 80 	movl   $0x8010a2b6,(%esp)
80108a66:	e8 e9 7a ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80108a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80108a6e:	8b 40 08             	mov    0x8(%eax),%eax
80108a71:	85 c0                	test   %eax,%eax
80108a73:	75 0c                	jne    80108a81 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80108a75:	c7 04 24 cc a2 10 80 	movl   $0x8010a2cc,(%esp)
80108a7c:	e8 d3 7a ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
80108a81:	8b 45 08             	mov    0x8(%ebp),%eax
80108a84:	8b 40 04             	mov    0x4(%eax),%eax
80108a87:	85 c0                	test   %eax,%eax
80108a89:	75 0c                	jne    80108a97 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80108a8b:	c7 04 24 e1 a2 10 80 	movl   $0x8010a2e1,(%esp)
80108a92:	e8 bd 7a ff ff       	call   80100554 <panic>

  pushcli();
80108a97:	e8 36 cd ff ff       	call   801057d2 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108a9c:	e8 a6 ba ff ff       	call   80104547 <mycpu>
80108aa1:	89 c3                	mov    %eax,%ebx
80108aa3:	e8 9f ba ff ff       	call   80104547 <mycpu>
80108aa8:	83 c0 08             	add    $0x8,%eax
80108aab:	89 c6                	mov    %eax,%esi
80108aad:	e8 95 ba ff ff       	call   80104547 <mycpu>
80108ab2:	83 c0 08             	add    $0x8,%eax
80108ab5:	c1 e8 10             	shr    $0x10,%eax
80108ab8:	89 c7                	mov    %eax,%edi
80108aba:	e8 88 ba ff ff       	call   80104547 <mycpu>
80108abf:	83 c0 08             	add    $0x8,%eax
80108ac2:	c1 e8 18             	shr    $0x18,%eax
80108ac5:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108acc:	67 00 
80108ace:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108ad5:	89 f9                	mov    %edi,%ecx
80108ad7:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108add:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108ae3:	83 e2 f0             	and    $0xfffffff0,%edx
80108ae6:	83 ca 09             	or     $0x9,%edx
80108ae9:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108aef:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108af5:	83 ca 10             	or     $0x10,%edx
80108af8:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108afe:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108b04:	83 e2 9f             	and    $0xffffff9f,%edx
80108b07:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108b0d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108b13:	83 ca 80             	or     $0xffffff80,%edx
80108b16:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108b1c:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108b22:	83 e2 f0             	and    $0xfffffff0,%edx
80108b25:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108b2b:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108b31:	83 e2 ef             	and    $0xffffffef,%edx
80108b34:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108b3a:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108b40:	83 e2 df             	and    $0xffffffdf,%edx
80108b43:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108b49:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108b4f:	83 ca 40             	or     $0x40,%edx
80108b52:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108b58:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108b5e:	83 e2 7f             	and    $0x7f,%edx
80108b61:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108b67:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108b6d:	e8 d5 b9 ff ff       	call   80104547 <mycpu>
80108b72:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80108b78:	83 e2 ef             	and    $0xffffffef,%edx
80108b7b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108b81:	e8 c1 b9 ff ff       	call   80104547 <mycpu>
80108b86:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108b8c:	e8 b6 b9 ff ff       	call   80104547 <mycpu>
80108b91:	8b 55 08             	mov    0x8(%ebp),%edx
80108b94:	8b 52 08             	mov    0x8(%edx),%edx
80108b97:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108b9d:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108ba0:	e8 a2 b9 ff ff       	call   80104547 <mycpu>
80108ba5:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108bab:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80108bb2:	e8 30 f9 ff ff       	call   801084e7 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80108bba:	8b 40 04             	mov    0x4(%eax),%eax
80108bbd:	05 00 00 00 80       	add    $0x80000000,%eax
80108bc2:	89 04 24             	mov    %eax,(%esp)
80108bc5:	e8 32 f9 ff ff       	call   801084fc <lcr3>
  popcli();
80108bca:	e8 4d cc ff ff       	call   8010581c <popcli>
}
80108bcf:	83 c4 1c             	add    $0x1c,%esp
80108bd2:	5b                   	pop    %ebx
80108bd3:	5e                   	pop    %esi
80108bd4:	5f                   	pop    %edi
80108bd5:	5d                   	pop    %ebp
80108bd6:	c3                   	ret    

80108bd7 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108bd7:	55                   	push   %ebp
80108bd8:	89 e5                	mov    %esp,%ebp
80108bda:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108bdd:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108be4:	76 0c                	jbe    80108bf2 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108be6:	c7 04 24 f5 a2 10 80 	movl   $0x8010a2f5,(%esp)
80108bed:	e8 62 79 ff ff       	call   80100554 <panic>
  mem = kalloc();
80108bf2:	e8 3f a3 ff ff       	call   80102f36 <kalloc>
80108bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108bfa:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108c01:	00 
80108c02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108c09:	00 
80108c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c0d:	89 04 24             	mov    %eax,(%esp)
80108c10:	e8 c1 cc ff ff       	call   801058d6 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c18:	05 00 00 00 80       	add    $0x80000000,%eax
80108c1d:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108c24:	00 
80108c25:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108c29:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108c30:	00 
80108c31:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108c38:	00 
80108c39:	8b 45 08             	mov    0x8(%ebp),%eax
80108c3c:	89 04 24             	mov    %eax,(%esp)
80108c3f:	e8 9c fc ff ff       	call   801088e0 <mappages>
  memmove(mem, init, sz);
80108c44:	8b 45 10             	mov    0x10(%ebp),%eax
80108c47:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c55:	89 04 24             	mov    %eax,(%esp)
80108c58:	e8 42 cd ff ff       	call   8010599f <memmove>
}
80108c5d:	c9                   	leave  
80108c5e:	c3                   	ret    

80108c5f <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108c5f:	55                   	push   %ebp
80108c60:	89 e5                	mov    %esp,%ebp
80108c62:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108c65:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c68:	25 ff 0f 00 00       	and    $0xfff,%eax
80108c6d:	85 c0                	test   %eax,%eax
80108c6f:	74 0c                	je     80108c7d <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108c71:	c7 04 24 10 a3 10 80 	movl   $0x8010a310,(%esp)
80108c78:	e8 d7 78 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108c7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c84:	e9 a6 00 00 00       	jmp    80108d2f <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c8f:	01 d0                	add    %edx,%eax
80108c91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108c98:	00 
80108c99:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c9d:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca0:	89 04 24             	mov    %eax,(%esp)
80108ca3:	e8 9c fb ff ff       	call   80108844 <walkpgdir>
80108ca8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108cab:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108caf:	75 0c                	jne    80108cbd <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108cb1:	c7 04 24 33 a3 10 80 	movl   $0x8010a333,(%esp)
80108cb8:	e8 97 78 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108cbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cc0:	8b 00                	mov    (%eax),%eax
80108cc2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cc7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108cca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ccd:	8b 55 18             	mov    0x18(%ebp),%edx
80108cd0:	29 c2                	sub    %eax,%edx
80108cd2:	89 d0                	mov    %edx,%eax
80108cd4:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108cd9:	77 0f                	ja     80108cea <loaduvm+0x8b>
      n = sz - i;
80108cdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cde:	8b 55 18             	mov    0x18(%ebp),%edx
80108ce1:	29 c2                	sub    %eax,%edx
80108ce3:	89 d0                	mov    %edx,%eax
80108ce5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108ce8:	eb 07                	jmp    80108cf1 <loaduvm+0x92>
    else
      n = PGSIZE;
80108cea:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cf4:	8b 55 14             	mov    0x14(%ebp),%edx
80108cf7:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108cfa:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108cfd:	05 00 00 00 80       	add    $0x80000000,%eax
80108d02:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108d05:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108d09:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d11:	8b 45 10             	mov    0x10(%ebp),%eax
80108d14:	89 04 24             	mov    %eax,(%esp)
80108d17:	e8 a2 92 ff ff       	call   80101fbe <readi>
80108d1c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108d1f:	74 07                	je     80108d28 <loaduvm+0xc9>
      return -1;
80108d21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d26:	eb 18                	jmp    80108d40 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108d28:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d32:	3b 45 18             	cmp    0x18(%ebp),%eax
80108d35:	0f 82 4e ff ff ff    	jb     80108c89 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108d3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d40:	c9                   	leave  
80108d41:	c3                   	ret    

80108d42 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108d42:	55                   	push   %ebp
80108d43:	89 e5                	mov    %esp,%ebp
80108d45:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108d48:	8b 45 10             	mov    0x10(%ebp),%eax
80108d4b:	85 c0                	test   %eax,%eax
80108d4d:	79 0a                	jns    80108d59 <allocuvm+0x17>
    return 0;
80108d4f:	b8 00 00 00 00       	mov    $0x0,%eax
80108d54:	e9 fd 00 00 00       	jmp    80108e56 <allocuvm+0x114>
  if(newsz < oldsz)
80108d59:	8b 45 10             	mov    0x10(%ebp),%eax
80108d5c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d5f:	73 08                	jae    80108d69 <allocuvm+0x27>
    return oldsz;
80108d61:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d64:	e9 ed 00 00 00       	jmp    80108e56 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108d69:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d6c:	05 ff 0f 00 00       	add    $0xfff,%eax
80108d71:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d76:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108d79:	e9 c9 00 00 00       	jmp    80108e47 <allocuvm+0x105>
    mem = kalloc();
80108d7e:	e8 b3 a1 ff ff       	call   80102f36 <kalloc>
80108d83:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108d86:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d8a:	75 2f                	jne    80108dbb <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108d8c:	c7 04 24 51 a3 10 80 	movl   $0x8010a351,(%esp)
80108d93:	e8 29 76 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108d98:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d9b:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d9f:	8b 45 10             	mov    0x10(%ebp),%eax
80108da2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108da6:	8b 45 08             	mov    0x8(%ebp),%eax
80108da9:	89 04 24             	mov    %eax,(%esp)
80108dac:	e8 a7 00 00 00       	call   80108e58 <deallocuvm>
      return 0;
80108db1:	b8 00 00 00 00       	mov    $0x0,%eax
80108db6:	e9 9b 00 00 00       	jmp    80108e56 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108dbb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108dc2:	00 
80108dc3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108dca:	00 
80108dcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dce:	89 04 24             	mov    %eax,(%esp)
80108dd1:	e8 00 cb ff ff       	call   801058d6 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108dd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dd9:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de2:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108de9:	00 
80108dea:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108dee:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108df5:	00 
80108df6:	89 44 24 04          	mov    %eax,0x4(%esp)
80108dfa:	8b 45 08             	mov    0x8(%ebp),%eax
80108dfd:	89 04 24             	mov    %eax,(%esp)
80108e00:	e8 db fa ff ff       	call   801088e0 <mappages>
80108e05:	85 c0                	test   %eax,%eax
80108e07:	79 37                	jns    80108e40 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108e09:	c7 04 24 69 a3 10 80 	movl   $0x8010a369,(%esp)
80108e10:	e8 ac 75 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108e15:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e18:	89 44 24 08          	mov    %eax,0x8(%esp)
80108e1c:	8b 45 10             	mov    0x10(%ebp),%eax
80108e1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e23:	8b 45 08             	mov    0x8(%ebp),%eax
80108e26:	89 04 24             	mov    %eax,(%esp)
80108e29:	e8 2a 00 00 00       	call   80108e58 <deallocuvm>
      kfree(mem);
80108e2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e31:	89 04 24             	mov    %eax,(%esp)
80108e34:	e8 0e a0 ff ff       	call   80102e47 <kfree>
      return 0;
80108e39:	b8 00 00 00 00       	mov    $0x0,%eax
80108e3e:	eb 16                	jmp    80108e56 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108e40:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e4a:	3b 45 10             	cmp    0x10(%ebp),%eax
80108e4d:	0f 82 2b ff ff ff    	jb     80108d7e <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108e53:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108e56:	c9                   	leave  
80108e57:	c3                   	ret    

80108e58 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108e58:	55                   	push   %ebp
80108e59:	89 e5                	mov    %esp,%ebp
80108e5b:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108e5e:	8b 45 10             	mov    0x10(%ebp),%eax
80108e61:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e64:	72 08                	jb     80108e6e <deallocuvm+0x16>
    return oldsz;
80108e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e69:	e9 ac 00 00 00       	jmp    80108f1a <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108e6e:	8b 45 10             	mov    0x10(%ebp),%eax
80108e71:	05 ff 0f 00 00       	add    $0xfff,%eax
80108e76:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108e7e:	e9 88 00 00 00       	jmp    80108f0b <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e8d:	00 
80108e8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e92:	8b 45 08             	mov    0x8(%ebp),%eax
80108e95:	89 04 24             	mov    %eax,(%esp)
80108e98:	e8 a7 f9 ff ff       	call   80108844 <walkpgdir>
80108e9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108ea0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108ea4:	75 14                	jne    80108eba <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ea9:	c1 e8 16             	shr    $0x16,%eax
80108eac:	40                   	inc    %eax
80108ead:	c1 e0 16             	shl    $0x16,%eax
80108eb0:	2d 00 10 00 00       	sub    $0x1000,%eax
80108eb5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108eb8:	eb 4a                	jmp    80108f04 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ebd:	8b 00                	mov    (%eax),%eax
80108ebf:	83 e0 01             	and    $0x1,%eax
80108ec2:	85 c0                	test   %eax,%eax
80108ec4:	74 3e                	je     80108f04 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108ec6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec9:	8b 00                	mov    (%eax),%eax
80108ecb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ed0:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108ed3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108ed7:	75 0c                	jne    80108ee5 <deallocuvm+0x8d>
        panic("kfree");
80108ed9:	c7 04 24 85 a3 10 80 	movl   $0x8010a385,(%esp)
80108ee0:	e8 6f 76 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108ee5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ee8:	05 00 00 00 80       	add    $0x80000000,%eax
80108eed:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108ef0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ef3:	89 04 24             	mov    %eax,(%esp)
80108ef6:	e8 4c 9f ff ff       	call   80102e47 <kfree>
      *pte = 0;
80108efb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108efe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108f04:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108f0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f0e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108f11:	0f 82 6c ff ff ff    	jb     80108e83 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108f17:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108f1a:	c9                   	leave  
80108f1b:	c3                   	ret    

80108f1c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108f1c:	55                   	push   %ebp
80108f1d:	89 e5                	mov    %esp,%ebp
80108f1f:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108f22:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108f26:	75 0c                	jne    80108f34 <freevm+0x18>
    panic("freevm: no pgdir");
80108f28:	c7 04 24 8b a3 10 80 	movl   $0x8010a38b,(%esp)
80108f2f:	e8 20 76 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108f34:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f3b:	00 
80108f3c:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108f43:	80 
80108f44:	8b 45 08             	mov    0x8(%ebp),%eax
80108f47:	89 04 24             	mov    %eax,(%esp)
80108f4a:	e8 09 ff ff ff       	call   80108e58 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108f4f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f56:	eb 44                	jmp    80108f9c <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f5b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f62:	8b 45 08             	mov    0x8(%ebp),%eax
80108f65:	01 d0                	add    %edx,%eax
80108f67:	8b 00                	mov    (%eax),%eax
80108f69:	83 e0 01             	and    $0x1,%eax
80108f6c:	85 c0                	test   %eax,%eax
80108f6e:	74 29                	je     80108f99 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f73:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80108f7d:	01 d0                	add    %edx,%eax
80108f7f:	8b 00                	mov    (%eax),%eax
80108f81:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f86:	05 00 00 00 80       	add    $0x80000000,%eax
80108f8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f91:	89 04 24             	mov    %eax,(%esp)
80108f94:	e8 ae 9e ff ff       	call   80102e47 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108f99:	ff 45 f4             	incl   -0xc(%ebp)
80108f9c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108fa3:	76 b3                	jbe    80108f58 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108fa5:	8b 45 08             	mov    0x8(%ebp),%eax
80108fa8:	89 04 24             	mov    %eax,(%esp)
80108fab:	e8 97 9e ff ff       	call   80102e47 <kfree>
}
80108fb0:	c9                   	leave  
80108fb1:	c3                   	ret    

80108fb2 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108fb2:	55                   	push   %ebp
80108fb3:	89 e5                	mov    %esp,%ebp
80108fb5:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108fb8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108fbf:	00 
80108fc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fc7:	8b 45 08             	mov    0x8(%ebp),%eax
80108fca:	89 04 24             	mov    %eax,(%esp)
80108fcd:	e8 72 f8 ff ff       	call   80108844 <walkpgdir>
80108fd2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108fd5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108fd9:	75 0c                	jne    80108fe7 <clearpteu+0x35>
    panic("clearpteu");
80108fdb:	c7 04 24 9c a3 10 80 	movl   $0x8010a39c,(%esp)
80108fe2:	e8 6d 75 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fea:	8b 00                	mov    (%eax),%eax
80108fec:	83 e0 fb             	and    $0xfffffffb,%eax
80108fef:	89 c2                	mov    %eax,%edx
80108ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ff4:	89 10                	mov    %edx,(%eax)
}
80108ff6:	c9                   	leave  
80108ff7:	c3                   	ret    

80108ff8 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108ff8:	55                   	push   %ebp
80108ff9:	89 e5                	mov    %esp,%ebp
80108ffb:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108ffe:	e8 73 f9 ff ff       	call   80108976 <setupkvm>
80109003:	89 45 f0             	mov    %eax,-0x10(%ebp)
80109006:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010900a:	75 0a                	jne    80109016 <copyuvm+0x1e>
    return 0;
8010900c:	b8 00 00 00 00       	mov    $0x0,%eax
80109011:	e9 f8 00 00 00       	jmp    8010910e <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80109016:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010901d:	e9 cb 00 00 00       	jmp    801090ed <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80109022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109025:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010902c:	00 
8010902d:	89 44 24 04          	mov    %eax,0x4(%esp)
80109031:	8b 45 08             	mov    0x8(%ebp),%eax
80109034:	89 04 24             	mov    %eax,(%esp)
80109037:	e8 08 f8 ff ff       	call   80108844 <walkpgdir>
8010903c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010903f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80109043:	75 0c                	jne    80109051 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80109045:	c7 04 24 a6 a3 10 80 	movl   $0x8010a3a6,(%esp)
8010904c:	e8 03 75 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80109051:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109054:	8b 00                	mov    (%eax),%eax
80109056:	83 e0 01             	and    $0x1,%eax
80109059:	85 c0                	test   %eax,%eax
8010905b:	75 0c                	jne    80109069 <copyuvm+0x71>
      panic("copyuvm: page not present");
8010905d:	c7 04 24 c0 a3 10 80 	movl   $0x8010a3c0,(%esp)
80109064:	e8 eb 74 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80109069:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010906c:	8b 00                	mov    (%eax),%eax
8010906e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109073:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80109076:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109079:	8b 00                	mov    (%eax),%eax
8010907b:	25 ff 0f 00 00       	and    $0xfff,%eax
80109080:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80109083:	e8 ae 9e ff ff       	call   80102f36 <kalloc>
80109088:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010908b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010908f:	75 02                	jne    80109093 <copyuvm+0x9b>
      goto bad;
80109091:	eb 6b                	jmp    801090fe <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80109093:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109096:	05 00 00 00 80       	add    $0x80000000,%eax
8010909b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801090a2:	00 
801090a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801090a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090aa:	89 04 24             	mov    %eax,(%esp)
801090ad:	e8 ed c8 ff ff       	call   8010599f <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
801090b2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801090b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801090b8:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
801090be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090c1:	89 54 24 10          	mov    %edx,0x10(%esp)
801090c5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801090c9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801090d0:	00 
801090d1:	89 44 24 04          	mov    %eax,0x4(%esp)
801090d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090d8:	89 04 24             	mov    %eax,(%esp)
801090db:	e8 00 f8 ff ff       	call   801088e0 <mappages>
801090e0:	85 c0                	test   %eax,%eax
801090e2:	79 02                	jns    801090e6 <copyuvm+0xee>
      goto bad;
801090e4:	eb 18                	jmp    801090fe <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801090e6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801090ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090f0:	3b 45 0c             	cmp    0xc(%ebp),%eax
801090f3:	0f 82 29 ff ff ff    	jb     80109022 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
801090f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090fc:	eb 10                	jmp    8010910e <copyuvm+0x116>

bad:
  freevm(d);
801090fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109101:	89 04 24             	mov    %eax,(%esp)
80109104:	e8 13 fe ff ff       	call   80108f1c <freevm>
  return 0;
80109109:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010910e:	c9                   	leave  
8010910f:	c3                   	ret    

80109110 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109110:	55                   	push   %ebp
80109111:	89 e5                	mov    %esp,%ebp
80109113:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109116:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010911d:	00 
8010911e:	8b 45 0c             	mov    0xc(%ebp),%eax
80109121:	89 44 24 04          	mov    %eax,0x4(%esp)
80109125:	8b 45 08             	mov    0x8(%ebp),%eax
80109128:	89 04 24             	mov    %eax,(%esp)
8010912b:	e8 14 f7 ff ff       	call   80108844 <walkpgdir>
80109130:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80109133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109136:	8b 00                	mov    (%eax),%eax
80109138:	83 e0 01             	and    $0x1,%eax
8010913b:	85 c0                	test   %eax,%eax
8010913d:	75 07                	jne    80109146 <uva2ka+0x36>
    return 0;
8010913f:	b8 00 00 00 00       	mov    $0x0,%eax
80109144:	eb 22                	jmp    80109168 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109149:	8b 00                	mov    (%eax),%eax
8010914b:	83 e0 04             	and    $0x4,%eax
8010914e:	85 c0                	test   %eax,%eax
80109150:	75 07                	jne    80109159 <uva2ka+0x49>
    return 0;
80109152:	b8 00 00 00 00       	mov    $0x0,%eax
80109157:	eb 0f                	jmp    80109168 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80109159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010915c:	8b 00                	mov    (%eax),%eax
8010915e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109163:	05 00 00 00 80       	add    $0x80000000,%eax
}
80109168:	c9                   	leave  
80109169:	c3                   	ret    

8010916a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010916a:	55                   	push   %ebp
8010916b:	89 e5                	mov    %esp,%ebp
8010916d:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109170:	8b 45 10             	mov    0x10(%ebp),%eax
80109173:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109176:	e9 87 00 00 00       	jmp    80109202 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
8010917b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010917e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80109183:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109186:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109189:	89 44 24 04          	mov    %eax,0x4(%esp)
8010918d:	8b 45 08             	mov    0x8(%ebp),%eax
80109190:	89 04 24             	mov    %eax,(%esp)
80109193:	e8 78 ff ff ff       	call   80109110 <uva2ka>
80109198:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010919b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010919f:	75 07                	jne    801091a8 <copyout+0x3e>
      return -1;
801091a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801091a6:	eb 69                	jmp    80109211 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801091a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801091ab:	8b 55 ec             	mov    -0x14(%ebp),%edx
801091ae:	29 c2                	sub    %eax,%edx
801091b0:	89 d0                	mov    %edx,%eax
801091b2:	05 00 10 00 00       	add    $0x1000,%eax
801091b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801091ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091bd:	3b 45 14             	cmp    0x14(%ebp),%eax
801091c0:	76 06                	jbe    801091c8 <copyout+0x5e>
      n = len;
801091c2:	8b 45 14             	mov    0x14(%ebp),%eax
801091c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801091c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091cb:	8b 55 0c             	mov    0xc(%ebp),%edx
801091ce:	29 c2                	sub    %eax,%edx
801091d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801091d3:	01 c2                	add    %eax,%edx
801091d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801091dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801091df:	89 44 24 04          	mov    %eax,0x4(%esp)
801091e3:	89 14 24             	mov    %edx,(%esp)
801091e6:	e8 b4 c7 ff ff       	call   8010599f <memmove>
    len -= n;
801091eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ee:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801091f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091f4:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801091f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801091fa:	05 00 10 00 00       	add    $0x1000,%eax
801091ff:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80109202:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80109206:	0f 85 6f ff ff ff    	jne    8010917b <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
8010920c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109211:	c9                   	leave  
80109212:	c3                   	ret    
	...

80109214 <memcpy2>:

struct container containers[MAX_CONTAINERS];

void*
memcpy2(void *dst, const void *src, uint n)
{
80109214:	55                   	push   %ebp
80109215:	89 e5                	mov    %esp,%ebp
80109217:	83 ec 18             	sub    $0x18,%esp
  return memmove(dst, src, n);
8010921a:	8b 45 10             	mov    0x10(%ebp),%eax
8010921d:	89 44 24 08          	mov    %eax,0x8(%esp)
80109221:	8b 45 0c             	mov    0xc(%ebp),%eax
80109224:	89 44 24 04          	mov    %eax,0x4(%esp)
80109228:	8b 45 08             	mov    0x8(%ebp),%eax
8010922b:	89 04 24             	mov    %eax,(%esp)
8010922e:	e8 6c c7 ff ff       	call   8010599f <memmove>
}
80109233:	c9                   	leave  
80109234:	c3                   	ret    

80109235 <strcpy>:

char* strcpy(char *s, char *t){
80109235:	55                   	push   %ebp
80109236:	89 e5                	mov    %esp,%ebp
80109238:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010923b:	8b 45 08             	mov    0x8(%ebp),%eax
8010923e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
80109241:	90                   	nop
80109242:	8b 45 08             	mov    0x8(%ebp),%eax
80109245:	8d 50 01             	lea    0x1(%eax),%edx
80109248:	89 55 08             	mov    %edx,0x8(%ebp)
8010924b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010924e:	8d 4a 01             	lea    0x1(%edx),%ecx
80109251:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80109254:	8a 12                	mov    (%edx),%dl
80109256:	88 10                	mov    %dl,(%eax)
80109258:	8a 00                	mov    (%eax),%al
8010925a:	84 c0                	test   %al,%al
8010925c:	75 e4                	jne    80109242 <strcpy+0xd>
    ;
  return os;
8010925e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109261:	c9                   	leave  
80109262:	c3                   	ret    

80109263 <strcmp>:

int
strcmp(const char *p, const char *q)
{
80109263:	55                   	push   %ebp
80109264:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
80109266:	eb 06                	jmp    8010926e <strcmp+0xb>
    p++, q++;
80109268:	ff 45 08             	incl   0x8(%ebp)
8010926b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
8010926e:	8b 45 08             	mov    0x8(%ebp),%eax
80109271:	8a 00                	mov    (%eax),%al
80109273:	84 c0                	test   %al,%al
80109275:	74 0e                	je     80109285 <strcmp+0x22>
80109277:	8b 45 08             	mov    0x8(%ebp),%eax
8010927a:	8a 10                	mov    (%eax),%dl
8010927c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010927f:	8a 00                	mov    (%eax),%al
80109281:	38 c2                	cmp    %al,%dl
80109283:	74 e3                	je     80109268 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
80109285:	8b 45 08             	mov    0x8(%ebp),%eax
80109288:	8a 00                	mov    (%eax),%al
8010928a:	0f b6 d0             	movzbl %al,%edx
8010928d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109290:	8a 00                	mov    (%eax),%al
80109292:	0f b6 c0             	movzbl %al,%eax
80109295:	29 c2                	sub    %eax,%edx
80109297:	89 d0                	mov    %edx,%eax
}
80109299:	5d                   	pop    %ebp
8010929a:	c3                   	ret    

8010929b <set_root_inode>:

// struct con

void set_root_inode(char* name){
8010929b:	55                   	push   %ebp
8010929c:	89 e5                	mov    %esp,%ebp
8010929e:	53                   	push   %ebx
8010929f:	83 ec 14             	sub    $0x14,%esp

	containers[find(name)].root = namei(name);
801092a2:	8b 45 08             	mov    0x8(%ebp),%eax
801092a5:	89 04 24             	mov    %eax,(%esp)
801092a8:	e8 6a 01 00 00       	call   80109417 <find>
801092ad:	89 c3                	mov    %eax,%ebx
801092af:	8b 45 08             	mov    0x8(%ebp),%eax
801092b2:	89 04 24             	mov    %eax,(%esp)
801092b5:	e8 0e 95 ff ff       	call   801027c8 <namei>
801092ba:	89 c2                	mov    %eax,%edx
801092bc:	89 d8                	mov    %ebx,%eax
801092be:	01 c0                	add    %eax,%eax
801092c0:	01 d8                	add    %ebx,%eax
801092c2:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
801092c9:	01 c8                	add    %ecx,%eax
801092cb:	c1 e0 02             	shl    $0x2,%eax
801092ce:	05 50 8d 11 80       	add    $0x80118d50,%eax
801092d3:	89 50 08             	mov    %edx,0x8(%eax)

}
801092d6:	83 c4 14             	add    $0x14,%esp
801092d9:	5b                   	pop    %ebx
801092da:	5d                   	pop    %ebp
801092db:	c3                   	ret    

801092dc <get_name>:

void get_name(int vc_num, char* name){
801092dc:	55                   	push   %ebp
801092dd:	89 e5                	mov    %esp,%ebp
801092df:	83 ec 28             	sub    $0x28,%esp

	char* name2 = containers[vc_num].name;
801092e2:	8b 55 08             	mov    0x8(%ebp),%edx
801092e5:	89 d0                	mov    %edx,%eax
801092e7:	01 c0                	add    %eax,%eax
801092e9:	01 d0                	add    %edx,%eax
801092eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801092f2:	01 d0                	add    %edx,%eax
801092f4:	c1 e0 02             	shl    $0x2,%eax
801092f7:	83 c0 10             	add    $0x10,%eax
801092fa:	05 20 8d 11 80       	add    $0x80118d20,%eax
801092ff:	83 c0 08             	add    $0x8,%eax
80109302:	89 45 f0             	mov    %eax,-0x10(%ebp)
	int i = 0;
80109305:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	while(name2[i])
8010930c:	eb 03                	jmp    80109311 <get_name+0x35>
	{
		i++;
8010930e:	ff 45 f4             	incl   -0xc(%ebp)

void get_name(int vc_num, char* name){

	char* name2 = containers[vc_num].name;
	int i = 0;
	while(name2[i])
80109311:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109314:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109317:	01 d0                	add    %edx,%eax
80109319:	8a 00                	mov    (%eax),%al
8010931b:	84 c0                	test   %al,%al
8010931d:	75 ef                	jne    8010930e <get_name+0x32>
	{
		i++;
	}
	memcpy2(name, name2, i);
8010931f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109322:	89 44 24 08          	mov    %eax,0x8(%esp)
80109326:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109329:	89 44 24 04          	mov    %eax,0x4(%esp)
8010932d:	8b 45 0c             	mov    0xc(%ebp),%eax
80109330:	89 04 24             	mov    %eax,(%esp)
80109333:	e8 dc fe ff ff       	call   80109214 <memcpy2>
	name[i] = '\0';
80109338:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010933b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010933e:	01 d0                	add    %edx,%eax
80109340:	c6 00 00             	movb   $0x0,(%eax)
}
80109343:	c9                   	leave  
80109344:	c3                   	ret    

80109345 <get_used>:

int get_used(){
80109345:	55                   	push   %ebp
80109346:	89 e5                	mov    %esp,%ebp
80109348:	83 ec 18             	sub    $0x18,%esp
	int x = 0;
8010934b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109352:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109359:	eb 3c                	jmp    80109397 <get_used+0x52>
		if(strcmp(containers[i].name, "") == 0){
8010935b:	8b 55 f8             	mov    -0x8(%ebp),%edx
8010935e:	89 d0                	mov    %edx,%eax
80109360:	01 c0                	add    %eax,%eax
80109362:	01 d0                	add    %edx,%eax
80109364:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010936b:	01 d0                	add    %edx,%eax
8010936d:	c1 e0 02             	shl    $0x2,%eax
80109370:	83 c0 10             	add    $0x10,%eax
80109373:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109378:	83 c0 08             	add    $0x8,%eax
8010937b:	c7 44 24 04 dc a3 10 	movl   $0x8010a3dc,0x4(%esp)
80109382:	80 
80109383:	89 04 24             	mov    %eax,(%esp)
80109386:	e8 d8 fe ff ff       	call   80109263 <strcmp>
8010938b:	85 c0                	test   %eax,%eax
8010938d:	75 02                	jne    80109391 <get_used+0x4c>
			continue;
8010938f:	eb 03                	jmp    80109394 <get_used+0x4f>
		}
		x++;
80109391:	ff 45 fc             	incl   -0x4(%ebp)
}

int get_used(){
	int x = 0;
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109394:	ff 45 f8             	incl   -0x8(%ebp)
80109397:	83 7d f8 03          	cmpl   $0x3,-0x8(%ebp)
8010939b:	7e be                	jle    8010935b <get_used+0x16>
		if(strcmp(containers[i].name, "") == 0){
			continue;
		}
		x++;
	}
	return x;
8010939d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801093a0:	c9                   	leave  
801093a1:	c3                   	ret    

801093a2 <g_name>:

char* g_name(int vc_bun){
801093a2:	55                   	push   %ebp
801093a3:	89 e5                	mov    %esp,%ebp
	return containers[vc_bun].name;
801093a5:	8b 55 08             	mov    0x8(%ebp),%edx
801093a8:	89 d0                	mov    %edx,%eax
801093aa:	01 c0                	add    %eax,%eax
801093ac:	01 d0                	add    %edx,%eax
801093ae:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093b5:	01 d0                	add    %edx,%eax
801093b7:	c1 e0 02             	shl    $0x2,%eax
801093ba:	83 c0 10             	add    $0x10,%eax
801093bd:	05 20 8d 11 80       	add    $0x80118d20,%eax
801093c2:	83 c0 08             	add    $0x8,%eax
}
801093c5:	5d                   	pop    %ebp
801093c6:	c3                   	ret    

801093c7 <is_full>:

int is_full(){
801093c7:	55                   	push   %ebp
801093c8:	89 e5                	mov    %esp,%ebp
801093ca:	83 ec 28             	sub    $0x28,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801093cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801093d4:	eb 34                	jmp    8010940a <is_full+0x43>
		if(strlen(containers[i].name) == 0){
801093d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801093d9:	89 d0                	mov    %edx,%eax
801093db:	01 c0                	add    %eax,%eax
801093dd:	01 d0                	add    %edx,%eax
801093df:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801093e6:	01 d0                	add    %edx,%eax
801093e8:	c1 e0 02             	shl    $0x2,%eax
801093eb:	83 c0 10             	add    $0x10,%eax
801093ee:	05 20 8d 11 80       	add    $0x80118d20,%eax
801093f3:	83 c0 08             	add    $0x8,%eax
801093f6:	89 04 24             	mov    %eax,(%esp)
801093f9:	e8 2b c7 ff ff       	call   80105b29 <strlen>
801093fe:	85 c0                	test   %eax,%eax
80109400:	75 05                	jne    80109407 <is_full+0x40>
			return i;
80109402:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109405:	eb 0e                	jmp    80109415 <is_full+0x4e>
	return containers[vc_bun].name;
}

int is_full(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
80109407:	ff 45 f4             	incl   -0xc(%ebp)
8010940a:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
8010940e:	7e c6                	jle    801093d6 <is_full+0xf>
		if(strlen(containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80109410:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80109415:	c9                   	leave  
80109416:	c3                   	ret    

80109417 <find>:

int find(char* name){
80109417:	55                   	push   %ebp
80109418:	89 e5                	mov    %esp,%ebp
8010941a:	83 ec 18             	sub    $0x18,%esp
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
8010941d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109424:	eb 54                	jmp    8010947a <find+0x63>
		if(strcmp(name, "") == 0){
80109426:	c7 44 24 04 dc a3 10 	movl   $0x8010a3dc,0x4(%esp)
8010942d:	80 
8010942e:	8b 45 08             	mov    0x8(%ebp),%eax
80109431:	89 04 24             	mov    %eax,(%esp)
80109434:	e8 2a fe ff ff       	call   80109263 <strcmp>
80109439:	85 c0                	test   %eax,%eax
8010943b:	75 02                	jne    8010943f <find+0x28>
			continue;
8010943d:	eb 38                	jmp    80109477 <find+0x60>
		}
		if(strcmp(name, containers[i].name) == 0){
8010943f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109442:	89 d0                	mov    %edx,%eax
80109444:	01 c0                	add    %eax,%eax
80109446:	01 d0                	add    %edx,%eax
80109448:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010944f:	01 d0                	add    %edx,%eax
80109451:	c1 e0 02             	shl    $0x2,%eax
80109454:	83 c0 10             	add    $0x10,%eax
80109457:	05 20 8d 11 80       	add    $0x80118d20,%eax
8010945c:	83 c0 08             	add    $0x8,%eax
8010945f:	89 44 24 04          	mov    %eax,0x4(%esp)
80109463:	8b 45 08             	mov    0x8(%ebp),%eax
80109466:	89 04 24             	mov    %eax,(%esp)
80109469:	e8 f5 fd ff ff       	call   80109263 <strcmp>
8010946e:	85 c0                	test   %eax,%eax
80109470:	75 05                	jne    80109477 <find+0x60>
			return i;
80109472:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109475:	eb 0e                	jmp    80109485 <find+0x6e>
}

int find(char* name){
	int i;

	for(i = 0; i < MAX_CONTAINERS; i++){
80109477:	ff 45 fc             	incl   -0x4(%ebp)
8010947a:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
8010947e:	7e a6                	jle    80109426 <find+0xf>
		}
		if(strcmp(name, containers[i].name) == 0){
			return i;
		}
	}
	return -1;
80109480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80109485:	c9                   	leave  
80109486:	c3                   	ret    

80109487 <get_max_proc>:

int get_max_proc(int vc_num){
80109487:	55                   	push   %ebp
80109488:	89 e5                	mov    %esp,%ebp
8010948a:	57                   	push   %edi
8010948b:	56                   	push   %esi
8010948c:	53                   	push   %ebx
8010948d:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80109490:	8b 55 08             	mov    0x8(%ebp),%edx
80109493:	89 d0                	mov    %edx,%eax
80109495:	01 c0                	add    %eax,%eax
80109497:	01 d0                	add    %edx,%eax
80109499:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094a0:	01 d0                	add    %edx,%eax
801094a2:	c1 e0 02             	shl    $0x2,%eax
801094a5:	05 20 8d 11 80       	add    $0x80118d20,%eax
801094aa:	8d 55 b8             	lea    -0x48(%ebp),%edx
801094ad:	89 c3                	mov    %eax,%ebx
801094af:	b8 0f 00 00 00       	mov    $0xf,%eax
801094b4:	89 d7                	mov    %edx,%edi
801094b6:	89 de                	mov    %ebx,%esi
801094b8:	89 c1                	mov    %eax,%ecx
801094ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_proc;
801094bc:	8b 45 bc             	mov    -0x44(%ebp),%eax
}
801094bf:	83 c4 40             	add    $0x40,%esp
801094c2:	5b                   	pop    %ebx
801094c3:	5e                   	pop    %esi
801094c4:	5f                   	pop    %edi
801094c5:	5d                   	pop    %ebp
801094c6:	c3                   	ret    

801094c7 <get_container>:

struct container* get_container(int vc_num){
801094c7:	55                   	push   %ebp
801094c8:	89 e5                	mov    %esp,%ebp
801094ca:	83 ec 10             	sub    $0x10,%esp
	struct container* cont = &containers[vc_num];
801094cd:	8b 55 08             	mov    0x8(%ebp),%edx
801094d0:	89 d0                	mov    %edx,%eax
801094d2:	01 c0                	add    %eax,%eax
801094d4:	01 d0                	add    %edx,%eax
801094d6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801094dd:	01 d0                	add    %edx,%eax
801094df:	c1 e0 02             	shl    $0x2,%eax
801094e2:	05 20 8d 11 80       	add    $0x80118d20,%eax
801094e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
	return cont;
801094ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801094ed:	c9                   	leave  
801094ee:	c3                   	ret    

801094ef <get_max_mem>:

int get_max_mem(int vc_num){
801094ef:	55                   	push   %ebp
801094f0:	89 e5                	mov    %esp,%ebp
801094f2:	57                   	push   %edi
801094f3:	56                   	push   %esi
801094f4:	53                   	push   %ebx
801094f5:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801094f8:	8b 55 08             	mov    0x8(%ebp),%edx
801094fb:	89 d0                	mov    %edx,%eax
801094fd:	01 c0                	add    %eax,%eax
801094ff:	01 d0                	add    %edx,%eax
80109501:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109508:	01 d0                	add    %edx,%eax
8010950a:	c1 e0 02             	shl    $0x2,%eax
8010950d:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109512:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109515:	89 c3                	mov    %eax,%ebx
80109517:	b8 0f 00 00 00       	mov    $0xf,%eax
8010951c:	89 d7                	mov    %edx,%edi
8010951e:	89 de                	mov    %ebx,%esi
80109520:	89 c1                	mov    %eax,%ecx
80109522:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_mem; 
80109524:	8b 45 b8             	mov    -0x48(%ebp),%eax
}
80109527:	83 c4 40             	add    $0x40,%esp
8010952a:	5b                   	pop    %ebx
8010952b:	5e                   	pop    %esi
8010952c:	5f                   	pop    %edi
8010952d:	5d                   	pop    %ebp
8010952e:	c3                   	ret    

8010952f <get_max_disk>:

int get_max_disk(int vc_num){
8010952f:	55                   	push   %ebp
80109530:	89 e5                	mov    %esp,%ebp
80109532:	57                   	push   %edi
80109533:	56                   	push   %esi
80109534:	53                   	push   %ebx
80109535:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80109538:	8b 55 08             	mov    0x8(%ebp),%edx
8010953b:	89 d0                	mov    %edx,%eax
8010953d:	01 c0                	add    %eax,%eax
8010953f:	01 d0                	add    %edx,%eax
80109541:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109548:	01 d0                	add    %edx,%eax
8010954a:	c1 e0 02             	shl    $0x2,%eax
8010954d:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109552:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109555:	89 c3                	mov    %eax,%ebx
80109557:	b8 0f 00 00 00       	mov    $0xf,%eax
8010955c:	89 d7                	mov    %edx,%edi
8010955e:	89 de                	mov    %ebx,%esi
80109560:	89 c1                	mov    %eax,%ecx
80109562:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.max_disk;
80109564:	8b 45 c0             	mov    -0x40(%ebp),%eax
}
80109567:	83 c4 40             	add    $0x40,%esp
8010956a:	5b                   	pop    %ebx
8010956b:	5e                   	pop    %esi
8010956c:	5f                   	pop    %edi
8010956d:	5d                   	pop    %ebp
8010956e:	c3                   	ret    

8010956f <get_curr_proc>:

int get_curr_proc(int vc_num){
8010956f:	55                   	push   %ebp
80109570:	89 e5                	mov    %esp,%ebp
80109572:	57                   	push   %edi
80109573:	56                   	push   %esi
80109574:	53                   	push   %ebx
80109575:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
80109578:	8b 55 08             	mov    0x8(%ebp),%edx
8010957b:	89 d0                	mov    %edx,%eax
8010957d:	01 c0                	add    %eax,%eax
8010957f:	01 d0                	add    %edx,%eax
80109581:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109588:	01 d0                	add    %edx,%eax
8010958a:	c1 e0 02             	shl    $0x2,%eax
8010958d:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109592:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109595:	89 c3                	mov    %eax,%ebx
80109597:	b8 0f 00 00 00       	mov    $0xf,%eax
8010959c:	89 d7                	mov    %edx,%edi
8010959e:	89 de                	mov    %ebx,%esi
801095a0:	89 c1                	mov    %eax,%ecx
801095a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_proc;
801095a4:	8b 45 c8             	mov    -0x38(%ebp),%eax
}
801095a7:	83 c4 40             	add    $0x40,%esp
801095aa:	5b                   	pop    %ebx
801095ab:	5e                   	pop    %esi
801095ac:	5f                   	pop    %edi
801095ad:	5d                   	pop    %ebp
801095ae:	c3                   	ret    

801095af <get_curr_mem>:

int get_curr_mem(int vc_num){
801095af:	55                   	push   %ebp
801095b0:	89 e5                	mov    %esp,%ebp
801095b2:	57                   	push   %edi
801095b3:	56                   	push   %esi
801095b4:	53                   	push   %ebx
801095b5:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801095b8:	8b 55 08             	mov    0x8(%ebp),%edx
801095bb:	89 d0                	mov    %edx,%eax
801095bd:	01 c0                	add    %eax,%eax
801095bf:	01 d0                	add    %edx,%eax
801095c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801095c8:	01 d0                	add    %edx,%eax
801095ca:	c1 e0 02             	shl    $0x2,%eax
801095cd:	05 20 8d 11 80       	add    $0x80118d20,%eax
801095d2:	8d 55 b8             	lea    -0x48(%ebp),%edx
801095d5:	89 c3                	mov    %eax,%ebx
801095d7:	b8 0f 00 00 00       	mov    $0xf,%eax
801095dc:	89 d7                	mov    %edx,%edi
801095de:	89 de                	mov    %ebx,%esi
801095e0:	89 c1                	mov    %eax,%ecx
801095e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// cprintf("curr mem is called. Val : %d.\n", x.curr_mem);
	return x.curr_mem; 
801095e4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
}
801095e7:	83 c4 40             	add    $0x40,%esp
801095ea:	5b                   	pop    %ebx
801095eb:	5e                   	pop    %esi
801095ec:	5f                   	pop    %edi
801095ed:	5d                   	pop    %ebp
801095ee:	c3                   	ret    

801095ef <get_curr_disk>:

int get_curr_disk(int vc_num){
801095ef:	55                   	push   %ebp
801095f0:	89 e5                	mov    %esp,%ebp
801095f2:	57                   	push   %edi
801095f3:	56                   	push   %esi
801095f4:	53                   	push   %ebx
801095f5:	83 ec 40             	sub    $0x40,%esp
	struct container x = containers[vc_num];
801095f8:	8b 55 08             	mov    0x8(%ebp),%edx
801095fb:	89 d0                	mov    %edx,%eax
801095fd:	01 c0                	add    %eax,%eax
801095ff:	01 d0                	add    %edx,%eax
80109601:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109608:	01 d0                	add    %edx,%eax
8010960a:	c1 e0 02             	shl    $0x2,%eax
8010960d:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109612:	8d 55 b8             	lea    -0x48(%ebp),%edx
80109615:	89 c3                	mov    %eax,%ebx
80109617:	b8 0f 00 00 00       	mov    $0xf,%eax
8010961c:	89 d7                	mov    %edx,%edi
8010961e:	89 de                	mov    %ebx,%esi
80109620:	89 c1                	mov    %eax,%ecx
80109622:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	return x.curr_disk;	
80109624:	8b 45 cc             	mov    -0x34(%ebp),%eax
}
80109627:	83 c4 40             	add    $0x40,%esp
8010962a:	5b                   	pop    %ebx
8010962b:	5e                   	pop    %esi
8010962c:	5f                   	pop    %edi
8010962d:	5d                   	pop    %ebp
8010962e:	c3                   	ret    

8010962f <set_name>:

void set_name(char* name, int vc_num){
8010962f:	55                   	push   %ebp
80109630:	89 e5                	mov    %esp,%ebp
80109632:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, name);
80109635:	8b 55 0c             	mov    0xc(%ebp),%edx
80109638:	89 d0                	mov    %edx,%eax
8010963a:	01 c0                	add    %eax,%eax
8010963c:	01 d0                	add    %edx,%eax
8010963e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109645:	01 d0                	add    %edx,%eax
80109647:	c1 e0 02             	shl    $0x2,%eax
8010964a:	83 c0 10             	add    $0x10,%eax
8010964d:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109652:	8d 50 08             	lea    0x8(%eax),%edx
80109655:	8b 45 08             	mov    0x8(%ebp),%eax
80109658:	89 44 24 04          	mov    %eax,0x4(%esp)
8010965c:	89 14 24             	mov    %edx,(%esp)
8010965f:	e8 d1 fb ff ff       	call   80109235 <strcpy>
}
80109664:	c9                   	leave  
80109665:	c3                   	ret    

80109666 <set_max_mem>:

void set_max_mem(int mem, int vc_num){
80109666:	55                   	push   %ebp
80109667:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_mem = mem;
80109669:	8b 55 0c             	mov    0xc(%ebp),%edx
8010966c:	89 d0                	mov    %edx,%eax
8010966e:	01 c0                	add    %eax,%eax
80109670:	01 d0                	add    %edx,%eax
80109672:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109679:	01 d0                	add    %edx,%eax
8010967b:	c1 e0 02             	shl    $0x2,%eax
8010967e:	8d 90 20 8d 11 80    	lea    -0x7fee72e0(%eax),%edx
80109684:	8b 45 08             	mov    0x8(%ebp),%eax
80109687:	89 02                	mov    %eax,(%edx)
}
80109689:	5d                   	pop    %ebp
8010968a:	c3                   	ret    

8010968b <set_max_disk>:

void set_max_disk(int disk, int vc_num){
8010968b:	55                   	push   %ebp
8010968c:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_disk = disk;
8010968e:	8b 55 0c             	mov    0xc(%ebp),%edx
80109691:	89 d0                	mov    %edx,%eax
80109693:	01 c0                	add    %eax,%eax
80109695:	01 d0                	add    %edx,%eax
80109697:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010969e:	01 d0                	add    %edx,%eax
801096a0:	c1 e0 02             	shl    $0x2,%eax
801096a3:	8d 90 20 8d 11 80    	lea    -0x7fee72e0(%eax),%edx
801096a9:	8b 45 08             	mov    0x8(%ebp),%eax
801096ac:	89 42 08             	mov    %eax,0x8(%edx)
}
801096af:	5d                   	pop    %ebp
801096b0:	c3                   	ret    

801096b1 <set_max_proc>:

void set_max_proc(int procs, int vc_num){
801096b1:	55                   	push   %ebp
801096b2:	89 e5                	mov    %esp,%ebp
	containers[vc_num].max_proc = procs;
801096b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801096b7:	89 d0                	mov    %edx,%eax
801096b9:	01 c0                	add    %eax,%eax
801096bb:	01 d0                	add    %edx,%eax
801096bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096c4:	01 d0                	add    %edx,%eax
801096c6:	c1 e0 02             	shl    $0x2,%eax
801096c9:	8d 90 20 8d 11 80    	lea    -0x7fee72e0(%eax),%edx
801096cf:	8b 45 08             	mov    0x8(%ebp),%eax
801096d2:	89 42 04             	mov    %eax,0x4(%edx)
}
801096d5:	5d                   	pop    %ebp
801096d6:	c3                   	ret    

801096d7 <set_curr_mem>:

void set_curr_mem(int mem, int vc_num){
801096d7:	55                   	push   %ebp
801096d8:	89 e5                	mov    %esp,%ebp
801096da:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_mem + 1) > containers[vc_num].max_mem){
801096dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801096e0:	89 d0                	mov    %edx,%eax
801096e2:	01 c0                	add    %eax,%eax
801096e4:	01 d0                	add    %edx,%eax
801096e6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801096ed:	01 d0                	add    %edx,%eax
801096ef:	c1 e0 02             	shl    $0x2,%eax
801096f2:	05 20 8d 11 80       	add    $0x80118d20,%eax
801096f7:	8b 40 0c             	mov    0xc(%eax),%eax
801096fa:	8d 48 01             	lea    0x1(%eax),%ecx
801096fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80109700:	89 d0                	mov    %edx,%eax
80109702:	01 c0                	add    %eax,%eax
80109704:	01 d0                	add    %edx,%eax
80109706:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010970d:	01 d0                	add    %edx,%eax
8010970f:	c1 e0 02             	shl    $0x2,%eax
80109712:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109717:	8b 00                	mov    (%eax),%eax
80109719:	39 c1                	cmp    %eax,%ecx
8010971b:	7e 0e                	jle    8010972b <set_curr_mem+0x54>
		cprintf("Exceded memory resource; killing container");
8010971d:	c7 04 24 e0 a3 10 80 	movl   $0x8010a3e0,(%esp)
80109724:	e8 98 6c ff ff       	call   801003c1 <cprintf>
80109729:	eb 3d                	jmp    80109768 <set_curr_mem+0x91>
	}
	else{
		containers[vc_num].curr_mem = containers[vc_num].curr_mem + 1;
8010972b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010972e:	89 d0                	mov    %edx,%eax
80109730:	01 c0                	add    %eax,%eax
80109732:	01 d0                	add    %edx,%eax
80109734:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010973b:	01 d0                	add    %edx,%eax
8010973d:	c1 e0 02             	shl    $0x2,%eax
80109740:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109745:	8b 40 0c             	mov    0xc(%eax),%eax
80109748:	8d 48 01             	lea    0x1(%eax),%ecx
8010974b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010974e:	89 d0                	mov    %edx,%eax
80109750:	01 c0                	add    %eax,%eax
80109752:	01 d0                	add    %edx,%eax
80109754:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010975b:	01 d0                	add    %edx,%eax
8010975d:	c1 e0 02             	shl    $0x2,%eax
80109760:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109765:	89 48 0c             	mov    %ecx,0xc(%eax)
	}
}
80109768:	c9                   	leave  
80109769:	c3                   	ret    

8010976a <reduce_curr_mem>:

void reduce_curr_mem(int mem, int vc_num){
8010976a:	55                   	push   %ebp
8010976b:	89 e5                	mov    %esp,%ebp
	containers[vc_num].curr_mem = containers[vc_num].curr_mem - 1;	
8010976d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109770:	89 d0                	mov    %edx,%eax
80109772:	01 c0                	add    %eax,%eax
80109774:	01 d0                	add    %edx,%eax
80109776:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010977d:	01 d0                	add    %edx,%eax
8010977f:	c1 e0 02             	shl    $0x2,%eax
80109782:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109787:	8b 40 0c             	mov    0xc(%eax),%eax
8010978a:	8d 48 ff             	lea    -0x1(%eax),%ecx
8010978d:	8b 55 0c             	mov    0xc(%ebp),%edx
80109790:	89 d0                	mov    %edx,%eax
80109792:	01 c0                	add    %eax,%eax
80109794:	01 d0                	add    %edx,%eax
80109796:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010979d:	01 d0                	add    %edx,%eax
8010979f:	c1 e0 02             	shl    $0x2,%eax
801097a2:	05 20 8d 11 80       	add    $0x80118d20,%eax
801097a7:	89 48 0c             	mov    %ecx,0xc(%eax)
}
801097aa:	5d                   	pop    %ebp
801097ab:	c3                   	ret    

801097ac <set_curr_disk>:

void set_curr_disk(int disk, int vc_num){
801097ac:	55                   	push   %ebp
801097ad:	89 e5                	mov    %esp,%ebp
801097af:	83 ec 18             	sub    $0x18,%esp
	if((containers[vc_num].curr_disk + disk)/1024 > containers[vc_num].max_disk){
801097b2:	8b 55 0c             	mov    0xc(%ebp),%edx
801097b5:	89 d0                	mov    %edx,%eax
801097b7:	01 c0                	add    %eax,%eax
801097b9:	01 d0                	add    %edx,%eax
801097bb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097c2:	01 d0                	add    %edx,%eax
801097c4:	c1 e0 02             	shl    $0x2,%eax
801097c7:	05 30 8d 11 80       	add    $0x80118d30,%eax
801097cc:	8b 50 04             	mov    0x4(%eax),%edx
801097cf:	8b 45 08             	mov    0x8(%ebp),%eax
801097d2:	01 d0                	add    %edx,%eax
801097d4:	85 c0                	test   %eax,%eax
801097d6:	79 05                	jns    801097dd <set_curr_disk+0x31>
801097d8:	05 ff 03 00 00       	add    $0x3ff,%eax
801097dd:	c1 f8 0a             	sar    $0xa,%eax
801097e0:	89 c1                	mov    %eax,%ecx
801097e2:	8b 55 0c             	mov    0xc(%ebp),%edx
801097e5:	89 d0                	mov    %edx,%eax
801097e7:	01 c0                	add    %eax,%eax
801097e9:	01 d0                	add    %edx,%eax
801097eb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801097f2:	01 d0                	add    %edx,%eax
801097f4:	c1 e0 02             	shl    $0x2,%eax
801097f7:	05 20 8d 11 80       	add    $0x80118d20,%eax
801097fc:	8b 40 08             	mov    0x8(%eax),%eax
801097ff:	39 c1                	cmp    %eax,%ecx
80109801:	7e 0e                	jle    80109811 <set_curr_disk+0x65>
		cprintf("Exceded disk resource; killing container");
80109803:	c7 04 24 0c a4 10 80 	movl   $0x8010a40c,(%esp)
8010980a:	e8 b2 6b ff ff       	call   801003c1 <cprintf>
8010980f:	eb 40                	jmp    80109851 <set_curr_disk+0xa5>
	}
	else{
		containers[vc_num].curr_disk += disk;
80109811:	8b 55 0c             	mov    0xc(%ebp),%edx
80109814:	89 d0                	mov    %edx,%eax
80109816:	01 c0                	add    %eax,%eax
80109818:	01 d0                	add    %edx,%eax
8010981a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109821:	01 d0                	add    %edx,%eax
80109823:	c1 e0 02             	shl    $0x2,%eax
80109826:	05 30 8d 11 80       	add    $0x80118d30,%eax
8010982b:	8b 50 04             	mov    0x4(%eax),%edx
8010982e:	8b 45 08             	mov    0x8(%ebp),%eax
80109831:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80109834:	8b 55 0c             	mov    0xc(%ebp),%edx
80109837:	89 d0                	mov    %edx,%eax
80109839:	01 c0                	add    %eax,%eax
8010983b:	01 d0                	add    %edx,%eax
8010983d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109844:	01 d0                	add    %edx,%eax
80109846:	c1 e0 02             	shl    $0x2,%eax
80109849:	05 30 8d 11 80       	add    $0x80118d30,%eax
8010984e:	89 48 04             	mov    %ecx,0x4(%eax)
	}
}
80109851:	c9                   	leave  
80109852:	c3                   	ret    

80109853 <set_curr_proc>:

void set_curr_proc(int procs, int vc_num){
80109853:	55                   	push   %ebp
80109854:	89 e5                	mov    %esp,%ebp
80109856:	83 ec 18             	sub    $0x18,%esp
	if(containers[vc_num].curr_proc + procs > containers[vc_num].max_proc){
80109859:	8b 55 0c             	mov    0xc(%ebp),%edx
8010985c:	89 d0                	mov    %edx,%eax
8010985e:	01 c0                	add    %eax,%eax
80109860:	01 d0                	add    %edx,%eax
80109862:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109869:	01 d0                	add    %edx,%eax
8010986b:	c1 e0 02             	shl    $0x2,%eax
8010986e:	05 30 8d 11 80       	add    $0x80118d30,%eax
80109873:	8b 10                	mov    (%eax),%edx
80109875:	8b 45 08             	mov    0x8(%ebp),%eax
80109878:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010987b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010987e:	89 d0                	mov    %edx,%eax
80109880:	01 c0                	add    %eax,%eax
80109882:	01 d0                	add    %edx,%eax
80109884:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010988b:	01 d0                	add    %edx,%eax
8010988d:	c1 e0 02             	shl    $0x2,%eax
80109890:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109895:	8b 40 04             	mov    0x4(%eax),%eax
80109898:	39 c1                	cmp    %eax,%ecx
8010989a:	7e 0e                	jle    801098aa <set_curr_proc+0x57>
		cprintf("Exceded procs resource; killing container");
8010989c:	c7 04 24 38 a4 10 80 	movl   $0x8010a438,(%esp)
801098a3:	e8 19 6b ff ff       	call   801003c1 <cprintf>
801098a8:	eb 3e                	jmp    801098e8 <set_curr_proc+0x95>
	}
	else{
		containers[vc_num].curr_proc += procs;
801098aa:	8b 55 0c             	mov    0xc(%ebp),%edx
801098ad:	89 d0                	mov    %edx,%eax
801098af:	01 c0                	add    %eax,%eax
801098b1:	01 d0                	add    %edx,%eax
801098b3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801098ba:	01 d0                	add    %edx,%eax
801098bc:	c1 e0 02             	shl    $0x2,%eax
801098bf:	05 30 8d 11 80       	add    $0x80118d30,%eax
801098c4:	8b 10                	mov    (%eax),%edx
801098c6:	8b 45 08             	mov    0x8(%ebp),%eax
801098c9:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
801098cc:	8b 55 0c             	mov    0xc(%ebp),%edx
801098cf:	89 d0                	mov    %edx,%eax
801098d1:	01 c0                	add    %eax,%eax
801098d3:	01 d0                	add    %edx,%eax
801098d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801098dc:	01 d0                	add    %edx,%eax
801098de:	c1 e0 02             	shl    $0x2,%eax
801098e1:	05 30 8d 11 80       	add    $0x80118d30,%eax
801098e6:	89 08                	mov    %ecx,(%eax)
	}
}
801098e8:	c9                   	leave  
801098e9:	c3                   	ret    

801098ea <max_containers>:

int max_containers(){
801098ea:	55                   	push   %ebp
801098eb:	89 e5                	mov    %esp,%ebp
	return MAX_CONTAINERS;
801098ed:	b8 04 00 00 00       	mov    $0x4,%eax
}
801098f2:	5d                   	pop    %ebp
801098f3:	c3                   	ret    

801098f4 <container_init>:

void container_init(){
801098f4:	55                   	push   %ebp
801098f5:	89 e5                	mov    %esp,%ebp
801098f7:	83 ec 18             	sub    $0x18,%esp
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801098fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80109901:	e9 f7 00 00 00       	jmp    801099fd <container_init+0x109>
		strcpy(containers[i].name, "");
80109906:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109909:	89 d0                	mov    %edx,%eax
8010990b:	01 c0                	add    %eax,%eax
8010990d:	01 d0                	add    %edx,%eax
8010990f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109916:	01 d0                	add    %edx,%eax
80109918:	c1 e0 02             	shl    $0x2,%eax
8010991b:	83 c0 10             	add    $0x10,%eax
8010991e:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109923:	83 c0 08             	add    $0x8,%eax
80109926:	c7 44 24 04 dc a3 10 	movl   $0x8010a3dc,0x4(%esp)
8010992d:	80 
8010992e:	89 04 24             	mov    %eax,(%esp)
80109931:	e8 ff f8 ff ff       	call   80109235 <strcpy>
		containers[i].max_proc = 6;
80109936:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109939:	89 d0                	mov    %edx,%eax
8010993b:	01 c0                	add    %eax,%eax
8010993d:	01 d0                	add    %edx,%eax
8010993f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109946:	01 d0                	add    %edx,%eax
80109948:	c1 e0 02             	shl    $0x2,%eax
8010994b:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109950:	c7 40 04 06 00 00 00 	movl   $0x6,0x4(%eax)
		containers[i].max_disk = 100;
80109957:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010995a:	89 d0                	mov    %edx,%eax
8010995c:	01 c0                	add    %eax,%eax
8010995e:	01 d0                	add    %edx,%eax
80109960:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109967:	01 d0                	add    %edx,%eax
80109969:	c1 e0 02             	shl    $0x2,%eax
8010996c:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109971:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
		containers[i].max_mem = 1000;
80109978:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010997b:	89 d0                	mov    %edx,%eax
8010997d:	01 c0                	add    %eax,%eax
8010997f:	01 d0                	add    %edx,%eax
80109981:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109988:	01 d0                	add    %edx,%eax
8010998a:	c1 e0 02             	shl    $0x2,%eax
8010998d:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109992:	c7 00 e8 03 00 00    	movl   $0x3e8,(%eax)
		containers[i].curr_proc = 0;
80109998:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010999b:	89 d0                	mov    %edx,%eax
8010999d:	01 c0                	add    %eax,%eax
8010999f:	01 d0                	add    %edx,%eax
801099a1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801099a8:	01 d0                	add    %edx,%eax
801099aa:	c1 e0 02             	shl    $0x2,%eax
801099ad:	05 30 8d 11 80       	add    $0x80118d30,%eax
801099b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		containers[i].curr_disk = 0;
801099b8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801099bb:	89 d0                	mov    %edx,%eax
801099bd:	01 c0                	add    %eax,%eax
801099bf:	01 d0                	add    %edx,%eax
801099c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801099c8:	01 d0                	add    %edx,%eax
801099ca:	c1 e0 02             	shl    $0x2,%eax
801099cd:	05 30 8d 11 80       	add    $0x80118d30,%eax
801099d2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
		containers[i].curr_mem = 0;
801099d9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801099dc:	89 d0                	mov    %edx,%eax
801099de:	01 c0                	add    %eax,%eax
801099e0:	01 d0                	add    %edx,%eax
801099e2:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801099e9:	01 d0                	add    %edx,%eax
801099eb:	c1 e0 02             	shl    $0x2,%eax
801099ee:	05 20 8d 11 80       	add    $0x80118d20,%eax
801099f3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
	return MAX_CONTAINERS;
}

void container_init(){
	int i;
	for(i = 0; i < MAX_CONTAINERS; i++){
801099fa:	ff 45 fc             	incl   -0x4(%ebp)
801099fd:	83 7d fc 03          	cmpl   $0x3,-0x4(%ebp)
80109a01:	0f 8e ff fe ff ff    	jle    80109906 <container_init+0x12>
		containers[i].max_mem = 1000;
		containers[i].curr_proc = 0;
		containers[i].curr_disk = 0;
		containers[i].curr_mem = 0;
	}
}
80109a07:	c9                   	leave  
80109a08:	c3                   	ret    

80109a09 <container_reset>:

void container_reset(int vc_num){
80109a09:	55                   	push   %ebp
80109a0a:	89 e5                	mov    %esp,%ebp
80109a0c:	83 ec 08             	sub    $0x8,%esp
	strcpy(containers[vc_num].name, "");
80109a0f:	8b 55 08             	mov    0x8(%ebp),%edx
80109a12:	89 d0                	mov    %edx,%eax
80109a14:	01 c0                	add    %eax,%eax
80109a16:	01 d0                	add    %edx,%eax
80109a18:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109a1f:	01 d0                	add    %edx,%eax
80109a21:	c1 e0 02             	shl    $0x2,%eax
80109a24:	83 c0 10             	add    $0x10,%eax
80109a27:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109a2c:	83 c0 08             	add    $0x8,%eax
80109a2f:	c7 44 24 04 dc a3 10 	movl   $0x8010a3dc,0x4(%esp)
80109a36:	80 
80109a37:	89 04 24             	mov    %eax,(%esp)
80109a3a:	e8 f6 f7 ff ff       	call   80109235 <strcpy>
	containers[vc_num].max_proc = 6;
80109a3f:	8b 55 08             	mov    0x8(%ebp),%edx
80109a42:	89 d0                	mov    %edx,%eax
80109a44:	01 c0                	add    %eax,%eax
80109a46:	01 d0                	add    %edx,%eax
80109a48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109a4f:	01 d0                	add    %edx,%eax
80109a51:	c1 e0 02             	shl    $0x2,%eax
80109a54:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109a59:	c7 40 04 06 00 00 00 	movl   $0x6,0x4(%eax)
	containers[vc_num].max_disk = 100;
80109a60:	8b 55 08             	mov    0x8(%ebp),%edx
80109a63:	89 d0                	mov    %edx,%eax
80109a65:	01 c0                	add    %eax,%eax
80109a67:	01 d0                	add    %edx,%eax
80109a69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109a70:	01 d0                	add    %edx,%eax
80109a72:	c1 e0 02             	shl    $0x2,%eax
80109a75:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109a7a:	c7 40 08 64 00 00 00 	movl   $0x64,0x8(%eax)
	containers[vc_num].max_mem = 300;
80109a81:	8b 55 08             	mov    0x8(%ebp),%edx
80109a84:	89 d0                	mov    %edx,%eax
80109a86:	01 c0                	add    %eax,%eax
80109a88:	01 d0                	add    %edx,%eax
80109a8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109a91:	01 d0                	add    %edx,%eax
80109a93:	c1 e0 02             	shl    $0x2,%eax
80109a96:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109a9b:	c7 00 2c 01 00 00    	movl   $0x12c,(%eax)
	containers[vc_num].curr_proc = 0;
80109aa1:	8b 55 08             	mov    0x8(%ebp),%edx
80109aa4:	89 d0                	mov    %edx,%eax
80109aa6:	01 c0                	add    %eax,%eax
80109aa8:	01 d0                	add    %edx,%eax
80109aaa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109ab1:	01 d0                	add    %edx,%eax
80109ab3:	c1 e0 02             	shl    $0x2,%eax
80109ab6:	05 30 8d 11 80       	add    $0x80118d30,%eax
80109abb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	containers[vc_num].curr_disk = 0;
80109ac1:	8b 55 08             	mov    0x8(%ebp),%edx
80109ac4:	89 d0                	mov    %edx,%eax
80109ac6:	01 c0                	add    %eax,%eax
80109ac8:	01 d0                	add    %edx,%eax
80109aca:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109ad1:	01 d0                	add    %edx,%eax
80109ad3:	c1 e0 02             	shl    $0x2,%eax
80109ad6:	05 30 8d 11 80       	add    $0x80118d30,%eax
80109adb:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	containers[vc_num].curr_mem = 0;
80109ae2:	8b 55 08             	mov    0x8(%ebp),%edx
80109ae5:	89 d0                	mov    %edx,%eax
80109ae7:	01 c0                	add    %eax,%eax
80109ae9:	01 d0                	add    %edx,%eax
80109aeb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80109af2:	01 d0                	add    %edx,%eax
80109af4:	c1 e0 02             	shl    $0x2,%eax
80109af7:	05 20 8d 11 80       	add    $0x80118d20,%eax
80109afc:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
80109b03:	c9                   	leave  
80109b04:	c3                   	ret    
